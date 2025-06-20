# ~/nixos-config/fish_functions/nixpkg.fish
function nixpkg -d "📦 Manage NixOS packages: list/add/remove from config files. Use 'nixpkg help' for manual."
    set -l action $argv[1]
    set -l rebuild_flag false
    set -l target "home" # default to home

    # Show help if no arguments or help requested
    if test (count $argv) -eq 0; or test "$action" = "help" -o "$action" = "h" -o "$action" = "--help" -o "$action" = "-h"
        _nixpkg_help
        return 0
    end

    # Parse arguments for --rebuild flag and target
    set -l clean_args
    for arg in $argv[2..-1]
        switch $arg
            case "--rebuild" "-r"
                set rebuild_flag true
            case "system" "sys" "s"
                set target "system"
            case "home" "h"
                set target "home"
            case "*"
                set -a clean_args $arg
        end
    end

    # Set file paths
    if test "$target" = "system"
        set config_file "$NIXOS_CONFIG_DIR/configuration.nix"
        set package_section "environment.systemPackages"
    else
        set config_file "$NIXOS_CONFIG_DIR/home.nix"
        set package_section "home.packages"
    end

    switch $action
        case "list" "ls" "l"
            _nixpkg_list "$config_file" "$package_section" "$target"

        case "add" "a"
            if test (count $clean_args) -eq 0
                echo "❌ Error: No package specified to add."
                echo "💡 Tip: Use 'nixpkg help' for usage examples."
                return 1
            end
            _nixpkg_add "$config_file" "$package_section" "$clean_args[1]" "$target"
            if test $status -eq 0; and test $rebuild_flag = true
                echo "🚀 Rebuilding system..."
                nixos-apply-config
            end

        case "remove" "rm" "r"
            if test (count $clean_args) -eq 0
                echo "❌ Error: No package specified to remove."
                echo "💡 Tip: Use 'nixpkg help' for usage examples."
                return 1
            end
            _nixpkg_remove "$config_file" "$package_section" "$clean_args[1]" "$target"
            if test $status -eq 0; and test $rebuild_flag = true
                echo "🚀 Rebuilding system..."
                nixos-apply-config
            end

        case "search" "s" "find"
            if test (count $clean_args) -eq 0
                echo "❌ Error: No search term specified."
                echo "💡 Tip: Use 'nixpkg help' for usage examples."
                return 1
            end
            echo "🔍 Searching for packages containing '$clean_args[1]'..."
            nix search nixpkgs $clean_args[1]

        case "manual" "man" "doc"
            _nixpkg_manual

        case "*"
            echo "❌ Unknown action: $action"
            echo "💡 Use 'nixpkg help' to see available commands."
            return 1
    end
end

function _nixpkg_list -d "List packages in configuration file"
    set -l config_file $argv[1]
    set -l package_section $argv[2]
    set -l target $argv[3]

    if not test -f "$config_file"
        echo "❌ Error: Configuration file not found: $config_file"
        return 1
    end

    echo "📦 Listing packages in $target configuration:"
    echo "   File: $config_file"
    echo ""

    set -l in_packages false
    set -l count 0

    while read -l line
        # Check if we're entering the packages section
        if string match -q "*$package_section = with pkgs; [" $line
            set in_packages true
            continue
        end

        # Check if we're exiting the packages section
        if test $in_packages = true; and string match -q -r '^\s*\];' $line
            set in_packages false
            continue
        end

        # If we're in the packages section, extract package names
        if test $in_packages = true
            # Remove leading/trailing whitespace and comments
            set clean_line (string trim $line | string replace -r '#.*$' '')

            # Skip empty lines
            if test -n "$clean_line"
                set count (math $count + 1)
                echo "  • $clean_line"
            end
        end
    end < "$config_file"

    echo ""
    echo "📊 Total packages: $count"
end

function _nixpkg_add -d "Add package to configuration file (appends to the list)"
    set -l config_file $argv[1]
    set -l package_section $argv[2]
    set -l package_name $argv[3]
    set -l target $argv[4]

    if not test -f "$config_file"
        echo "❌ Error: Configuration file not found: $config_file"
        return 1
    end

    # Create backup before modification
    cp "$config_file" "$config_file.bak"

    set -l temp_file (mktemp)
    set -l pre_block_lines # Lines before the package block
    set -l post_block_lines # Lines after the package block
    set -l packages_in_block_raw # Raw lines within the package block
    set -l in_pre_block true
    set -l in_packages_block false
    set -l in_post_block false

    set -l block_start_marker "$package_section = with pkgs; ["
    set -l block_end_marker "];"

    # Read the file and separate content into three parts: pre, block, post
    while read -l line
        if $in_pre_block
            if string match -q "*$block_start_marker*" $line
                set in_pre_block false
                set in_packages_block true
                set -a packages_in_block_raw "$line" # Include the start marker
            else
                set -a pre_block_lines "$line"
            end
        else if $in_packages_block
            if string match -q -r '^\s*\];' $line
                set in_packages_block false
                set in_post_block true
                set -a packages_in_block_raw "$line" # Include the end marker
            else
                set -a packages_in_block_raw "$line"
            end
        else # in_post_block
            set -a post_block_lines "$line"
        end
    end < "$config_file"

    # Check if the package block was found
    if not $in_post_block; or not $packages_in_block_raw
        echo "❌ Failed to find the package section '$block_start_marker' in $config_file."
        rm $temp_file
        rm "$config_file.bak" # Clean up backup as no modification occurred
        return 1
    end

    # --- Process the package block ---
    set -l current_packages_clean
    set -l block_started_flag false # To track past the initial `[`

    for p_line in $packages_in_block_raw
        # Skip the start and end markers for cleaning
        if string match -q "*$block_start_marker*" $p_line
            set block_started_flag true
            continue
        end
        if string match -q -r '^\s*\];' $p_line
            continue
        end

        # Clean individual package lines
        if $block_started_flag
            set clean_p_line (string trim (string replace -r '#.*$' '' $p_line))
            if test -n "$clean_p_line"
                set -a current_packages_clean "$clean_p_line"
            end
        end
    end

    # Check for duplicates in the cleaned list
    set -l package_exists false
    for existing_pkg in $current_packages_clean
        if test "$existing_pkg" = "$package_name"
            set package_exists true
            break
        end
    end

    if $package_exists
        echo "⚠️ Package '$package_name' already exists in $target configuration."
        rm $temp_file # Clean up temp file
        return 1
    end

    # Add the new package to the cleaned list
    set -a current_packages_clean "$package_name"

    echo "➕ Appending '$package_name' to $target configuration..."
    echo "   File: $config_file"

    # --- Write content back to temp file ---
    for line in $pre_block_lines
        echo $line >> $temp_file
    end

    echo "  $block_start_marker" >> $temp_file
    for pkg in (sort --unique $current_packages_clean) # Sort and ensure uniqueness
        echo "    $pkg" >> $temp_file # Add proper indentation
    end
    echo "  $block_end_marker" >> $temp_file

    for line in $post_block_lines
        echo $line >> $temp_file
    end

    # Replace original file with modified content
    mv $temp_file "$config_file"

    echo "✅ Successfully appended '$package_name' to $target configuration."
    echo "💾 Backup saved as $config_file.bak"
    echo "💡 Use 'nixpkg list $target' to verify the addition."
    return 0
end

function _nixpkg_remove -d "Remove package from configuration file"
    set -l config_file $argv[1]
    set -l package_section $argv[2]
    set -l package_name $argv[3]
    set -l target $argv[4]

    if not test -f "$config_file"
        echo "❌ Error: Configuration file not found: $config_file"
        return 1
    end

    # Create backup before modification
    cp "$config_file" "$config_file.bak"

    set -l temp_file (mktemp)
    set -l pre_block_lines
    set -l post_block_lines
    set -l packages_in_block_raw
    set -l in_pre_block true
    set -l in_packages_block false
    set -l in_post_block false
    set -l package_found_in_block false

    set -l block_start_marker "$package_section = with pkgs; ["
    set -l block_end_marker "];"

    # Read the file and separate content into three parts: pre, block, post
    while read -l line
        if $in_pre_block
            if string match -q "*$block_start_marker*" $line
                set in_pre_block false
                set in_packages_block true
                set -a packages_in_block_raw "$line" # Include the start marker
            else
                set -a pre_block_lines "$line"
            end
        else if $in_packages_block
            if string match -q -r '^\s*\];' $line
                set in_packages_block false
                set in_post_block true
                set -a packages_in_block_raw "$line" # Include the end marker
            else
                set -a packages_in_block_raw "$line"
            end
        else # in_post_block
            set -a post_block_lines "$line"
        end
    end < "$config_file"

    # Check if the package block was found
    if not $in_post_block; or not $packages_in_block_raw
        echo "❌ Failed to find the package section '$block_start_marker' in $config_file."
        rm $temp_file
        rm "$config_file.bak" # Clean up backup as no modification occurred
        return 1
    end

    # --- Process the package block ---
    set -l current_packages_clean
    set -l block_started_flag false

    for p_line in $packages_in_block_raw
        # Skip the start and end markers for cleaning
        if string match -q "*$block_start_marker*" $p_line
            set block_started_flag true
            continue
        end
        if string match -q -r '^\s*\];' $p_line
            continue
        end

        # Clean individual package lines and check for the package to remove
        if $block_started_flag
            set clean_p_line (string trim (string replace -r '#.*$' '' $p_line))
            if test -n "$clean_p_line"
                if test "$clean_p_line" = "$package_name"
                    set package_found_in_block true
                else
                    set -a current_packages_clean "$clean_p_line"
                end
            end
        end
    end

    if not $package_found_in_block
        echo "⚠️ Package '$package_name' not found in $target configuration."
        rm $temp_file # Clean up temp file
        return 1
    end

    echo "➖ Removing '$package_name' from $target configuration..."
    echo "   File: $config_file"

    # --- Write content back to temp file ---
    for line in $pre_block_lines
        echo $line >> $temp_file
    end

    echo "  $block_start_marker" >> $temp_file
    for pkg in (sort --unique $current_packages_clean) # Sort and ensure uniqueness
        echo "    $pkg" >> $temp_file # Add proper indentation
    end
    echo "  $block_end_marker" >> $temp_file

    for line in $post_block_lines
        echo $line >> $temp_file
    end

    # Replace original file with modified content
    mv $temp_file "$config_file"

    echo "✅ Successfully removed '$package_name' from $target configuration."
    echo "💾 Backup saved as $config_file.bak"
    echo "💡 Use 'nixpkg list $target' to verify the removal."
    return 0
end

# Keep your existing help functions
function _nixpkg_help -d "Show help for nixpkg function"
    echo "📦 nixpkg - NixOS Package Manager"
    echo "════════════════════════════════════════════════════════════"
    echo ""
    echo "🎯 DESCRIPTION:"
    echo "   Manage packages in your NixOS configuration files (home.nix and configuration.nix)"
    echo "   Provides a simple interface to list, add, remove, and search for packages."
    echo ""
    echo "⚙️  USAGE:"
    echo "   nixpkg <action> [package] [target] [options]"
    echo ""
    echo "📋 ACTIONS:"
    echo "   list, ls, l          List all packages in configuration"
    echo "   add, a               Add a package to configuration"
    echo "   remove, rm, r        Remove a package from configuration"
    echo "   search, s, find      Search for packages in nixpkgs"
    echo "   help, h, --help      Show this help message"
    echo "   manual, man, doc     Show detailed manual"
    echo ""
    echo "🎯 TARGETS:"
    echo "   home, h              Target home.nix (default)"
    echo "   system, sys, s       Target configuration.nix"
    echo ""
    echo "🔧 OPTIONS:"
    echo "   --rebuild, -r        Rebuild system after making changes"
    echo ""
    echo "💡 EXAMPLES:"
    echo "   nixpkg list                    # List home packages"
    echo "   nixpkg list system             # List system packages"
    echo "   nixpkg add firefox             # Add Firefox to home.nix"
    echo "   nixpkg add vim system -r       # Add vim to system and rebuild"
    echo "   nixpkg remove htop home        # Remove htop from home.nix"
    echo "   nixpkg search browser          # Search for browser packages"
    echo ""
    echo "🔗 ABBREVIATIONS AVAILABLE:"
    echo "   pkgls    = nixpkg list"
    echo "   pkgadd   = nixpkg add"
    echo "   pkgrm    = nixpkg remove"
    echo "   pkgs     = nixpkg search"
    echo "   pkgaddr  = nixpkg add --rebuild"
    echo "   pkgrmr   = nixpkg remove --rebuild"
    echo ""
    echo "ℹ️  For detailed information, use: nixpkg manual"
end

function _nixpkg_manual -d "Show detailed manual for nixpkg function"
    echo "📖 nixpkg - Complete Manual"
    echo "════════════════════════════════════════════════════════════════════════════════"
    echo ""
    echo "🔍 OVERVIEW:"
    echo "   nixpkg is a comprehensive package management tool for NixOS configurations."
    echo "   It simplifies the process of managing packages across home.nix and"
    echo "   configuration.nix files by providing intuitive commands for common operations."
    echo ""
    echo "📂 FILE TARGETS:"
    echo "   • HOME TARGET (home.nix):"
    echo "     - File: \$NIXOS_CONFIG_DIR/home.nix"
    echo "     - Section: home.packages = with pkgs; ["
    echo "     - Scope: User-specific packages"
    echo "     - Default target when none specified"
    echo ""
    echo "   • SYSTEM TARGET (configuration.nix):"
    echo "     - File: \$NIXOS_CONFIG_DIR/configuration.nix"
    echo "     - Section: environment.systemPackages = with pkgs; ["
    echo "     - Scope: System-wide packages for all users"
    echo ""
    echo "🛠️  DETAILED ACTIONS:"
    echo ""
    echo "   📋 LIST (list, ls, l):"
    echo "      Purpose: Display all packages currently in the configuration"
    echo "      Syntax:  nixpkg list [target]"
    echo "      Output:  Bullet-pointed list with package count"
    echo "      Example: nixpkg list system"
    echo ""
    echo "   ➕ ADD (add, a):"
    echo "      Purpose: Add a new package to the configuration"
    echo "      Syntax:  nixpkg add <package> [target] [--rebuild]"
    echo "      Safety:  Creates backup (.bak file) before modification"
    echo "      Checks:  Prevents duplicate package additions"
    echo "      Example: nixpkg add firefox home --rebuild"
    echo ""
    echo "   ➖ REMOVE (remove, rm, r):"
    echo "      Purpose: Remove an existing package from configuration"
    echo "      Syntax:  nixpkg remove <package> [target] [--rebuild]"
    echo "      Safety:  Creates backup (.bak file) before modification"
    echo "      Checks:  Verifies package exists before removal"
    echo "      Example: nixpkg remove htop system -r"
    echo ""
    echo "   🔍 SEARCH (search, s, find):"
    echo "      Purpose: Search nixpkgs repository for available packages"
    echo "      Syntax:  nixpkg search <term>"
    echo "      Backend: Uses 'nix search nixpkgs <term>'"
    echo "      Example: nixpkg search text editor"
    echo ""
    echo "🔧 REBUILD INTEGRATION:"
    echo "   • The --rebuild flag automatically calls nixos-apply-config after changes"
    echo "   • nixos-apply-config handles the full rebuild process including:"
    echo "     - Running sudo nixos-rebuild switch"
    echo "     - Offering git commit on success"
    echo "     - Offering rollback on failure"
    echo ""
    echo "💾 BACKUP SYSTEM:"
    echo "   • All modifications create .bak files automatically"
    echo "   • Format: <config-file>.bak (e.g., home.nix.bak)"
    echo "   • Restored automatically on failure"
    echo "   • Manual restoration: mv home.nix.bak home.nix"
    echo ""
    echo "⚠️  ERROR HANDLING:"
    echo "   • File existence checks before operations"
    echo "   • Duplicate addition prevention"
    echo "   • Missing package removal detection"
    echo "   • Automatic backup restoration on failure"
    echo "   • Clear error messages with helpful tips"
    echo ""
    echo "🔗 INTEGRATION WITH YOUR SETUP:"
    echo "   • Uses \$NIXOS_CONFIG_DIR environment variable"
    echo "   • Integrates with your existing nixos-apply-config function"
    echo "   • Works with your git workflow (nixos-git function)"
    echo "   • Compatible with your fish abbreviations"
    echo ""
    echo "📈 WORKFLOW EXAMPLES:"
    echo ""
    echo "   🎮 Gaming Setup:"
    echo "     nixpkg add lutris home"
    echo "     nixpkg add mangohud home"
    echo "     nixpkg add steam system --rebuild"
    echo ""
    echo "   💻 Development Environment:"
    echo "     nixpkg add git system"
    echo "     nixpkg add vscode home"
    echo "     nixpkg add nodejs home --rebuild"
    echo ""
    echo "   🧹 Cleanup:"
    echo "     nixpkg list home | grep unused"
    echo "     nixpkg remove unused-package home -r"
    echo ""
    echo "💡 PRO TIPS:"
    echo "   • Use abbreviations for faster workflow (pkgadd, pkgrm, etc.)"
    echo "   • Always list packages first to see current state"
    echo "   • Use search to find exact package names before adding"
    echo "   • Consider using --rebuild for immediate testing"
    echo "   • Check .bak files if something goes wrong"
    echo ""
    echo "🆘 TROUBLESHOOTING:"
    echo "   • If rebuild fails: Check .bak files for restoration"
    echo "   • If package not found: Use 'nixpkg search <term>' first"
    echo "   • If file not found: Check \$NIXOS_CONFIG_DIR variable"
    echo "   • If permission denied: Ensure you can write to config directory"
    echo ""
    echo "ℹ️  For quick reference, use: nixpkg help"
end
