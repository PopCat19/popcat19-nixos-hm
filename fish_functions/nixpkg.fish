function nixpkg -d "📦 Manage NixOS packages: list/add/remove from config files. Use 'nixpkg help' for manual."
    set -l action        $argv[1]
    set -l rebuild_flag  false
    set -l target        "home"    # default to home

    # Show help if no arguments or help requested
    if test (count $argv) -eq 0; or test "$action" = "help" -o "$action" = "h" -o \
        "$action" = "--help" -o "$action" = "-h"
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

    # Determine configuration files and package section based on target
    if test "$target" = "system"
        set config_file    "$NIXOS_CONFIG_DIR/configuration.nix"
        set package_section "environment.systemPackages"
    else
        # For home target, check priority order: home-packages.nix > home.nix
        set config_file ""
        set package_section ""

        # Check for home-packages.nix first (highest priority)
        if test -f "$NIXOS_CONFIG_DIR/home-packages.nix"
            set config_file "$NIXOS_CONFIG_DIR/home-packages.nix"
            set package_section "home.packages"
        # Check for other home-*.nix files
        else if test -n (find "$NIXOS_CONFIG_DIR" -name "home-*.nix" -type f 2>/dev/null | head -1)
            set config_file (find "$NIXOS_CONFIG_DIR" -name "home-*.nix" -type f | head -1)
            set package_section "home.packages"
        # Fall back to home.nix
        else if test -f "$NIXOS_CONFIG_DIR/home.nix"
            set config_file "$NIXOS_CONFIG_DIR/home.nix"
            set package_section "home.packages"
        else
            echo "❌ Error: No home configuration files found."
            echo "💡 Expected files: home-packages.nix, home-*.nix, or home.nix"
            return 1
        end
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
        _nixpkg_add "$config_file" "$package_section" \
            "$clean_args[1]" "$target"
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
        _nixpkg_remove "$config_file" "$package_section" \
            "$clean_args[1]" "$target"
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
    case "files" "f" "info"
        _nixpkg_show_files "$target"
    case "manual" "man" "doc"
        _nixpkg_manual
    case "*"
        echo "❌ Unknown action: $action"
        echo "💡 Use 'nixpkg help' to see available commands."
        return 1
    end
end

function _nixpkg_show_files -d "Show which configuration files are being used"
    set -l target $argv[1]

    echo "📁 Configuration File Information:"
    echo "════════════════════════════════════════════════════════════"
    echo ""

    if test "$target" = "system"
        echo "🖥️  SYSTEM TARGET:"
        echo "    Primary file: $NIXOS_CONFIG_DIR/configuration.nix"
        if test -f "$NIXOS_CONFIG_DIR/configuration.nix"
            echo "    Status: ✅ Found"
        else
            echo "    Status: ❌ Not found"
        end
    else
        echo "🏠 HOME TARGET (Priority Order):"

        # Check home-packages.nix (highest priority)
        echo "    1. home-packages.nix (highest priority)"
        if test -f "$NIXOS_CONFIG_DIR/home-packages.nix"
            echo "       Status: ✅ Found - USING THIS FILE"
            echo "       Path: $NIXOS_CONFIG_DIR/home-packages.nix"
        else
            echo "       Status: ⚠️  Not found"
        end

        # Check other home-*.nix files
        echo "    2. Other home-*.nix files (secondary priority)"
        set -l other_home_files (find "$NIXOS_CONFIG_DIR" -name "home-*.nix" -not -name "home-packages.nix" -type f 2>/dev/null)
        if test (count $other_home_files) -gt 0
            for file in $other_home_files
                set -l basename (basename "$file")
                if test -f "$NIXOS_CONFIG_DIR/home-packages.nix"
                    echo "       $basename: ✅ Found (available but not used)"
                else
                    echo "       $basename: ✅ Found - USING THIS FILE"
                    echo "       Path: $file"
                    break
                end
            end
        else
            echo "       Status: ⚠️  None found"
        end

        # Check home.nix (fallback)
        echo "    3. home.nix (fallback)"
        if test -f "$NIXOS_CONFIG_DIR/home.nix"
            if test -f "$NIXOS_CONFIG_DIR/home-packages.nix"; or test -n "$other_home_files"
                echo "       Status: ✅ Found (available but not used)"
            else
                echo "       Status: ✅ Found - USING THIS FILE"
                echo "       Path: $NIXOS_CONFIG_DIR/home.nix"
            end
        else
            echo "       Status: ❌ Not found"
        end
    end

    echo ""
    echo "💡 Use 'nixpkg list' to see packages in the active configuration file."
end

function _nixpkg_list -d "List packages in configuration file"
    set -l config_file    $argv[1]
    set -l package_section $argv[2]
    set -l target         $argv[3]

    if not test -f "$config_file"
        echo "❌ Error: Configuration file not found: $config_file"
        return 1
    end

    echo "📦 Listing packages in $target configuration:"
    echo "    File: $config_file"
    echo ""

    # Handle different file structures
    set -l in_packages false
    set -l count       0
    set -l brace_count 0

    while read -l line
        # Look for different package section patterns
        if string match -q "*$package_section = with pkgs; \[*" $line
            set in_packages true
            continue
        else if string match -q "*$package_section = import*" $line
            # Handle import-style package definitions
            echo "  ℹ️  Packages imported from external file"
            set -l import_file (string replace -r '.*import\s+([./\w-]+\.nix).*' '$1' $line)
            if test -f "$NIXOS_CONFIG_DIR/$import_file"
                echo "  📁 Import file: $import_file"
                _nixpkg_list_import_file "$NIXOS_CONFIG_DIR/$import_file"
            end
            return 0
        end

        # Handle package list extraction
        if test $in_packages = true
            # Count braces for nested structures
            set brace_count (math $brace_count + (string length (string replace -a -r '[^\[]' '' $line)))
            set brace_count (math $brace_count - (string length (string replace -a -r '[^\]]' '' $line)))

            # Check if we're exiting the packages section
            if test $brace_count -le 0; and string match -q "*];*" $line
                set in_packages false
                continue
            end

            # Extract package names
            set clean_line (string trim $line | string replace -r '#.*$' '')

            # Skip empty lines and lines with only punctuation
            if test -n "$clean_line"; and not string match -q -r '^\s*[\[\],;]+\s*$' "$clean_line"
                # Clean up package names (remove trailing punctuation)
                set clean_line (string replace -r '[\s,;]*$' '' $clean_line)
                if test -n "$clean_line"
                    set count (math $count + 1)
                    echo "  • $clean_line"
                end
            end
        end
    end < "$config_file"

    echo ""
    echo "📊 Total packages: $count"
end

function _nixpkg_list_import_file -d "List packages from imported file"
    set -l import_file $argv[1]

    if not test -f "$import_file"
        echo "  ❌ Import file not found: $import_file"
        return 1
    end

    set -l count 0
    while read -l line
        set clean_line (string trim $line | string replace -r '#.*$' '')
        if test -n "$clean_line"; and not string match -q -r '^\s*[\{\}\[\],;]+\s*$' "$clean_line"
            # Skip common nix keywords and structural elements
            if not string match -q -r '^\s*(with|pkgs|inputs|system|inherit|\{|\}|\[|\]|;|,)\s*' "$clean_line"
                set clean_line (string replace -r '[\s,;]*$' '' $clean_line)
                if test -n "$clean_line"
                    set count (math $count + 1)
                    echo "    • $clean_line"
                end
            end
        end
    end < "$import_file"

    echo "    📊 Imported packages: $count"
end

function _nixpkg_add -d "Add package to configuration file (appends to the list)"
    set -l config_file    $argv[1]
    set -l package_section $argv[2]
    set -l package_name   $argv[3]
    set -l target         $argv[4]

    if not test -f "$config_file"
        echo "❌ Error: Configuration file not found: $config_file"
        return 1
    end

    # Check if package already exists
    set -l package_exists false
    while read -l line
        set clean_line (string trim (string replace -r '#.*$' '' $line))
        if test "$clean_line" = "$package_name"
            set package_exists true
            break
        end
    end < "$config_file"

    if test $package_exists = true
        echo "⚠️ Package '$package_name' already exists in $target configuration."
        return 1
    end

    echo "➕ Adding '$package_name' to $target configuration..."
    echo "    File: $config_file"

    # Create backup
    cp "$config_file" "$config_file.bak"

    # Handle different file structures
    set -l temp_file  (mktemp)
    set -l added      false
    set -l in_packages false
    set -l brace_count 0

    while read -l line
        # Check for different package section patterns
        if string match -q "*$package_section = with pkgs; \[*" $line
            set in_packages true
            set brace_count 1
        else if string match -q "*$package_section = import*" $line
            echo "❌ Error: Cannot add packages to imported file structure."
            echo "💡 Please edit the imported file directly or use 'nixpkg files' to see structure."
            rm $temp_file
            mv "$config_file.bak" "$config_file"
            return 1
        end

        # Handle package list insertion
        if test $in_packages = true
            # Count braces for nested structures
            set brace_count (math $brace_count + (string length (string replace -a -r '[^\[]' '' $line)))
            set brace_count (math $brace_count - (string length (string replace -a -r '[^\]]' '' $line)))

            # Check if we're at the end of the packages section
            if test $brace_count -le 0; and string match -q -r '^\s*\];' $line
                # Add the new package before the closing bracket
                set -l indent (string replace -r '\];.*$' '' $line)
                echo "$indent$package_name" >> $temp_file
                set added true
                set in_packages false
            end
        end

        # Write the original line
        echo $line >> $temp_file
    end < "$config_file"

    # Replace the original file
    mv $temp_file "$config_file"

    if test $added = true
        echo "✅ Successfully added '$package_name' to $target configuration."
        echo "💾 Backup saved as $config_file.bak"
        echo "💡 Use 'nixpkg list $target' to verify the addition."
    else
        echo "❌ Failed to find package section in configuration file."
        mv "$config_file.bak" "$config_file"
        return 1
    end
end

function _nixpkg_remove -d "Remove package from configuration file"
    set -l config_file     $argv[1]
    set -l package_section $argv[2]
    set -l package_name    $argv[3]
    set -l target          $argv[4]

    if not test -f "$config_file"
        echo "❌ Error: Configuration file not found: $config_file"
        return 1
    end

    # Check if package exists
    set -l package_found false
    while read -l line
        set clean_line (string trim $line)
        if test "$clean_line" = "$package_name"
            set package_found true
            break
        end
    end < "$config_file"

    if test $package_found = false
        echo "⚠️ Package '$package_name' not found in $target configuration."
        echo "💡 Use 'nixpkg list $target' to see available packages."
        return 1
    end

    echo "➖ Removing '$package_name' from $target configuration..."
    echo "    File: $config_file"

    # Create backup
    cp "$config_file" "$config_file.bak"

    # Remove the package line using a temporary file approach
    set -l temp_file (mktemp)
    set -l removed   false

    while read -l line
        # Skip the line if it matches our package name exactly
        set clean_line (string trim $line)
        if test "$clean_line" = "$package_name"
            set removed true
            continue
        end
        echo $line >> $temp_file
    end < "$config_file"

    # Replace the original file
    mv $temp_file "$config_file"

    if test $removed = true
        echo "✅ Successfully removed '$package_name' from $target configuration."
        echo "💾 Backup saved as $config_file.bak"
        echo "💡 Use 'nixpkg list $target' to verify the removal."
    else
        echo "❌ Package not found or failed to remove."
        mv "$config_file.bak" "$config_file"
        return 1
    end
end

function _nixpkg_help -d "Show help for nixpkg function"
    echo "📦 nixpkg - NixOS Package Manager"
    echo "════════════════════════════════════════════════════════════"
    echo ""
    echo "🎯 DESCRIPTION:"
    echo "    Manage packages in your NixOS configuration files with intelligent file detection."
    echo "    Supports multi-file configurations including home-packages.nix, home-*.nix, and home.nix."
    echo ""
    echo "⚙️  USAGE:"
    echo "    nixpkg <action> [package] [target] [options]"
    echo ""
    echo "📋 ACTIONS:"
    echo "    list, ls, l          List all packages in configuration"
    echo "    add, a               Add a package to configuration"
    echo "    remove, rm, r        Remove a package from configuration"
    echo "    search, s, find      Search for packages in nixpkgs"
    echo "    files, f, info       Show which configuration files are being used"
    echo "    help, h, --help      Show this help message"
    echo "    manual, man, doc     Show detailed manual"
    echo ""
    echo "🎯 TARGETS:"
    echo "    home, h              Target home configuration (default)"
    echo "                         Priority: home-packages.nix > home-*.nix > home.nix"
    echo "    system, sys, s       Target configuration.nix"
    echo ""
    echo "🔧 OPTIONS:"
    echo "    --rebuild, -r        Rebuild system after making changes"
    echo ""
    echo "💡 EXAMPLES:"
    echo "    nixpkg files                   # Show configuration file structure"
    echo "    nixpkg list                    # List home packages (auto-detects file)"
    echo "    nixpkg list system             # List system packages"
    echo "    nixpkg add firefox             # Add Firefox to highest priority home file"
    echo "    nixpkg add vim system -r       # Add vim to system and rebuild"
    echo "    nixpkg remove htop home        # Remove htop from home configuration"
    echo "    nixpkg search browser          # Search for browser packages"
    echo ""
    echo "🔗 ABBREVIATIONS AVAILABLE:"
    echo "    pkgls    = nixpkg list"
    echo "    pkgadd   = nixpkg add"
    echo "    pkgrm    = nixpkg remove"
    echo "    pkgs     = nixpkg search"
    echo "    pkgaddr  = nixpkg add --rebuild"
    echo "    pkgrmr   = nixpkg remove --rebuild"
    echo "    pkgfiles = nixpkg files"
    echo ""
    echo "ℹ️  For detailed information, use: nixpkg manual"
end

function _nixpkg_manual -d "Show detailed manual for nixpkg function"
    echo "📖 nixpkg - Complete Manual"
    echo "════════════════════════════════════════════════════════════════════════════════"
    echo ""
    echo "🔍 OVERVIEW:"
    echo "    nixpkg is a comprehensive package management tool for NixOS configurations."
    echo "    It intelligently handles multi-file configurations with automatic file detection"
    echo "    and priority-based selection for home configurations."
    echo ""
    echo "📂 FILE TARGETS & PRIORITY:"
    echo ""
    echo "    🖥️  SYSTEM TARGET (configuration.nix):"
    echo "      - File: \$NIXOS_CONFIG_DIR/configuration.nix"
    echo "      - Section: environment.systemPackages = with pkgs; ["
    echo "      - Scope: System-wide packages for all users"
    echo ""
    echo "    🏠 HOME TARGET (Priority Order):"
    echo "      1. home-packages.nix (HIGHEST PRIORITY)"
    echo "         - File: \$NIXOS_CONFIG_DIR/home-packages.nix"
    echo "         - Section: home.packages = with pkgs; ["
    echo "         - Purpose: Dedicated package management file"
    echo ""
    echo "      2. Other home-*.nix files (SECONDARY PRIORITY)"
    echo "         - Files: Any file matching home-*.nix pattern"
    echo "         - Examples: home-theme.nix, home-screenshot.nix, etc."
    echo "         - Used only if home-packages.nix doesn't exist"
    echo ""
    echo "      3. home.nix (FALLBACK)"
    echo "         - File: \$NIXOS_CONFIG_DIR/home.nix"
    echo "         - Section: home.packages = with pkgs; ["
    echo "         - Used only if no other home-*.nix files exist"
    echo ""
    echo "🛠️  DETAILED ACTIONS:"
    echo ""
    echo "    📋 LIST (list, ls, l):"
    echo "        Purpose: Display all packages currently in the configuration"
    echo "        Syntax:  nixpkg list [target]"
    echo "        Features: Auto-detects file structure, handles imports"
    echo "        Output:  Bullet-pointed list with package count"
    echo "        Example: nixpkg list home"
    echo ""
    echo "    ➕ ADD (add, a):"
    echo "        Purpose: Add a new package to the configuration"
    echo "        Syntax:  nixpkg add <package> [target] [--rebuild]"
    echo "        Safety:  Creates backup (.bak file) before modification"
    echo "        Checks:  Prevents duplicate package additions"
    echo "        Smart:   Uses highest priority available file"
    echo "        Example: nixpkg add firefox home --rebuild"
    echo ""
    echo "    ➖ REMOVE (remove, rm, r):"
    echo "        Purpose: Remove an existing package from configuration"
    echo "        Syntax:  nixpkg remove <package> [target] [--rebuild]"
    echo "        Safety:  Creates backup (.bak file) before modification"
    echo "        Checks:  Verifies package exists before removal"
    echo "        Smart:   Searches across all applicable files"
    echo "        Example: nixpkg remove htop home -r"
    echo ""
    echo "    🔍 SEARCH (search, s, find):"
    echo "        Purpose: Search nixpkgs repository for available packages"
    echo "        Syntax:  nixpkg search <term>"
    echo "        Backend: Uses 'nix search nixpkgs <term>'"
    echo "        Example: nixpkg search text editor"
    echo ""
    echo "    📁 FILES (files, f, info):"
    echo "        Purpose: Show which configuration files are being used"
    echo "        Syntax:  nixpkg files [target]"
    echo "        Output:  Priority order, file status, active file"
    echo "        Example: nixpkg files home"
    echo ""
    echo "🔧 INTELLIGENT FEATURES:"
    echo "    • Automatic file detection and priority handling"
    echo "    • Support for import-style package definitions"
    echo "    • Backup system with automatic restoration on failure"
    echo "    • Duplicate prevention and existence checking"
    echo "    • Multi-file configuration support"
    echo ""
    echo "📈 WORKFLOW EXAMPLES:"
    echo ""
    echo "    🔍 Check Current Setup:"
    echo "      nixpkg files home          # See which files are available"
    echo "      nixpkg list home           # See current packages"
    echo ""
    echo "    🎮 Gaming Setup:"
    echo "      nixpkg add lutris home"
    echo "      nixpkg add mangohud home"
    echo "      nixpkg add steam system --rebuild"
    echo ""
    echo "    💻 Development Environment:"
    echo "      nixpkg add git system"
    echo "      nixpkg add vscode home"
    echo "      nixpkg add nodejs home --rebuild"
    echo ""
    echo "💡 PRO TIPS:"
    echo "    • Use 'nixpkg files' first to understand your configuration structure"
    echo "    • home-packages.nix is the preferred location for user packages"
    echo "    • Use abbreviations for faster workflow (pkgadd, pkgrm, etc.)"
    echo "    • Always check 'nixpkg list' to see current state"
    echo "    • Use search to find exact package names before adding"
    echo ""
    echo "🆘 TROUBLESHOOTING:"
    echo "    • File structure issues: Use 'nixpkg files' to diagnose"
    echo "    • Package not found: Use 'nixpkg search <term>' first"
    echo "    • Import errors: Cannot modify imported package files directly"
    echo "    • Permission issues: Check write access to config directory"
    echo ""
    echo "ℹ️  For quick reference, use: nixpkg help"
end
