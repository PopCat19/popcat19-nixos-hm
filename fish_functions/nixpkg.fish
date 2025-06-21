function nixpkg -d "📦 Manage NixOS packages: list/add/remove from config files. Use 'nixpkg help' for manual."
    set -l action        $argv[1]
    set -l rebuild_flag  false
    set -l rebuild_args  ""        # additional args for nixos-apply-config
    set -l target        "home"    # default to home
    set -l home_file_spec ""       # specific home file (e.g., "theme", "screenshot")

    # Show help if no arguments or help requested
    if test (count $argv) -eq 0; or test "$action" = "help" -o "$action" = "h" -o \
        "$action" = "--help" -o "$action" = "-h"
        _nixpkg_help
        return 0
    end

    # Parse arguments for --rebuild flag, target, and home file specification
    set -l clean_args
    for arg in $argv[2..-1]
        switch $arg
        case "--rebuild" "-r"
            set rebuild_flag true
        case "--fast" "--skip"
            set rebuild_flag true
            set rebuild_args "--fast"
        case "system" "sys" "s"
            set target "system"
        case "home" "h"
            set target "home"
        case "all"
            # Special case for listing all home files
            if test "$action" = "list" -o "$action" = "ls" -o "$action" = "l"
                set home_file_spec "all"
            else
                set -a clean_args $arg
            end
        case "*"
            # Check if this might be a home file specification
            if test "$target" = "home"; and test -z "$home_file_spec"; and \
               test -f "$NIXOS_CONFIG_DIR/home-$arg.nix"
                set home_file_spec $arg
            else
                set -a clean_args $arg
            end
        end
    end

    # Determine configuration files and package section based on target
    if test "$target" = "system"
        set config_file    "$NIXOS_CONFIG_DIR/configuration.nix"
        set package_section "environment.systemPackages"
    else
        # For home target, handle different modes
        if test "$home_file_spec" = "all"
            # Special handling for listing all home files
            set config_file "all"
            set package_section "home.packages"
        else if test -n "$home_file_spec"
            # Specific home file requested
            set config_file "$NIXOS_CONFIG_DIR/home-$home_file_spec.nix"
            set package_section "home.packages"
            if not test -f "$config_file"
                echo "❌ Error: Home configuration file not found: home-$home_file_spec.nix"
                echo "💡 Available home files:"
                _nixpkg_list_available_home_files
                return 1
            end
        else
            # Default priority order: home-packages.nix > other home-*.nix > home.nix
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
    end

    switch $action
    case "list" "ls" "l"
        if test "$config_file" = "all"
            _nixpkg_list_all_home_files
        else
            _nixpkg_list "$config_file" "$package_section" "$target" "$home_file_spec"
        end
    case "add" "a"
        if test (count $clean_args) -eq 0
            echo "❌ Error: No package specified to add."
            echo "💡 Tip: Use 'nixpkg help' for usage examples."
            return 1
        end
        _nixpkg_add "$config_file" "$package_section" \
            "$clean_args[1]" "$target" "$home_file_spec"
        if test $status -eq 0; and test $rebuild_flag = true
            echo "🚀 Rebuilding system..."
            if test -n "$rebuild_args"
                nixos-apply-config $rebuild_args
            else
                nixos-apply-config
            end
        end
    case "remove" "rm" "r"
        if test (count $clean_args) -eq 0
            echo "❌ Error: No package specified to remove."
            echo "💡 Tip: Use 'nixpkg help' for usage examples."
            return 1
        end
        _nixpkg_remove "$config_file" "$package_section" \
            "$clean_args[1]" "$target" "$home_file_spec"
        if test $status -eq 0; and test $rebuild_flag = true
            echo "🚀 Rebuilding system..."
            if test -n "$rebuild_args"
                nixos-apply-config $rebuild_args
            else
                nixos-apply-config
            end
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

        # List all home-*.nix files (secondary priority)
        echo "    2. Specific home-*.nix files (use: nixpkg list <name>)"
        set -l all_home_files (find "$NIXOS_CONFIG_DIR" -name "home-*.nix" -not -name "home-packages.nix" -type f 2>/dev/null | sort)
        if test (count $all_home_files) -gt 0
            for file in $all_home_files
                set -l basename (basename "$file")
                set -l name_part (string replace -r '^home-(.+)\.nix$' '$1' "$basename")
                if test -f "$NIXOS_CONFIG_DIR/home-packages.nix"
                    echo "       $basename: ✅ Found (use: nixpkg list $name_part)"
                else
                    echo "       $basename: ✅ Found - WOULD USE FIRST ONE"
                    echo "       Path: $file"
                end
            end
        else
            echo "       Status: ⚠️  None found"
        end

        # Check home.nix (fallback)
        echo "    3. home.nix (fallback)"
        if test -f "$NIXOS_CONFIG_DIR/home.nix"
            if test -f "$NIXOS_CONFIG_DIR/home-packages.nix"; or test (count $all_home_files) -gt 0
                echo "       Status: ✅ Found (available but not used by default)"
            else
                echo "       Status: ✅ Found - USING THIS FILE"
                echo "       Path: $NIXOS_CONFIG_DIR/home.nix"
            end
        else
            echo "       Status: ❌ Not found"
        end
    end

    echo ""
    echo "💡 Commands:"
    echo "   • 'nixpkg list' - List packages from primary home config"
    echo "   • 'nixpkg list all' - List packages from ALL home configs"
    echo "   • 'nixpkg list <name>' - List packages from home-<name>.nix"
    echo "   • 'nixpkg add <pkg> <name>' - Add package to home-<name>.nix"
end

function _nixpkg_list_all_home_files -d "List packages from all home configuration files"
    echo "📦 Listing packages from ALL home configuration files:"
    echo "══════════════════════════════════════════════════════════════════"
    echo ""

    set -l total_count 0
    set -l file_count 0

    # List packages from home-packages.nix if it exists
    if test -f "$NIXOS_CONFIG_DIR/home-packages.nix"
        echo "🏠 home-packages.nix (primary):"
        set file_count (math $file_count + 1)
        set -l count (_nixpkg_count_packages "$NIXOS_CONFIG_DIR/home-packages.nix" "home.packages")
        set total_count (math $total_count + $count)
        _nixpkg_list_simple "$NIXOS_CONFIG_DIR/home-packages.nix" "home.packages"
        echo ""
    end

    # List packages from all other home-*.nix files
    set -l other_home_files (find "$NIXOS_CONFIG_DIR" -name "home-*.nix" -not -name "home-packages.nix" -type f 2>/dev/null | sort)
    for file in $other_home_files
        set -l basename (basename "$file")
        set -l name_part (string replace -r '^home-(.+)\.nix$' '$1' "$basename")
        echo "🏠 $basename:"
        set file_count (math $file_count + 1)
        set -l count (_nixpkg_count_packages "$file" "home.packages")
        set total_count (math $total_count + $count)
        _nixpkg_list_simple "$file" "home.packages"
        echo ""
    end

    # List packages from home.nix if it exists and no other files were found
    if test -f "$NIXOS_CONFIG_DIR/home.nix"; and test $file_count -eq 0
        echo "🏠 home.nix (fallback):"
        set file_count (math $file_count + 1)
        set -l count (_nixpkg_count_packages "$NIXOS_CONFIG_DIR/home.nix" "home.packages")
        set total_count (math $total_count + $count)
        _nixpkg_list_simple "$NIXOS_CONFIG_DIR/home.nix" "home.packages"
        echo ""
    end

    if test $file_count -eq 0
        echo "❌ No home configuration files found."
        return 1
    end

    echo "📊 Summary: $total_count total packages across $file_count files"
end

function _nixpkg_list_available_home_files -d "List available home-*.nix files"
    set -l all_home_files (find "$NIXOS_CONFIG_DIR" -name "home-*.nix" -type f 2>/dev/null | sort)
    for file in $all_home_files
        set -l basename (basename "$file")
        set -l name_part (string replace -r '^home-(.+)\.nix$' '$1' "$basename")
        echo "   • $name_part ($basename)"
    end
    if test -f "$NIXOS_CONFIG_DIR/home.nix"
        echo "   • home (home.nix)"
    end
end

function _nixpkg_count_packages -d "Count packages in a configuration file"
    set -l config_file $argv[1]
    set -l package_section $argv[2]

    if not test -f "$config_file"
        echo 0
        return
    end

    set -l count 0
    set -l in_packages false
    set -l brace_count 0
    set -l in_shell_script false

    # Check if this is a function-style file (like home-packages.nix)
    set -l is_function_file false
    if string match -q "*home-packages.nix" $config_file
        set is_function_file true
    end

    while read -l line
        # Check for shell script start and skip entire script
        if string match -q "*writeShellScriptBin*" $line
            set in_shell_script true
            continue
        end

        # Skip lines while in shell script until we find the end
        if test $in_shell_script = true
            if string match -q "*'')*" $line
                set in_shell_script false
            end
            continue
        end

        # Look for different package section patterns
        if string match -q "*$package_section = with pkgs; \[*" $line
            set in_packages true
            set brace_count 1
            continue
        else if string match -q "*$package_section = with pkgs; [*" $line
            set in_packages true
            set brace_count 1
            continue
        else if test $is_function_file = true; and string match -q "*with pkgs; [*" $line
            # Handle function-style package files (home-packages.nix)
            set in_packages true
            set brace_count 1
            continue
        end

        # Handle package list extraction
        if test $in_packages = true
            # Count brackets for nested structures
            set brace_count (math $brace_count + (string length (string replace -a -r '[^\[]' '' $line)))
            set brace_count (math $brace_count - (string length (string replace -a -r '[^\]]' '' $line)))

            # Check if we're exiting the packages section
            if test $brace_count -le 0; and string match -q "*]*" $line
                set in_packages false
                continue
            end

            # Extract and validate package names
            set clean_line (string trim $line)
            set clean_line (string replace -r '#.*$' '' $clean_line)

            # Skip empty lines, comments, and lines with only punctuation
            if test -n "$clean_line"; and not string match -q -r '^\s*[\[\],;]+\s*$' "$clean_line"
                # Skip comment-only lines
                if not string match -q -r '^\s*#' "$clean_line"
                    # Clean up package names
                    set clean_line (string trim $clean_line)
                    set clean_line (string replace -r '[\s,;]*$' '' $clean_line)
                    # Only accept simple package names
                    if test -n "$clean_line"; and \
                       string match -q -r '^[a-zA-Z0-9._-]+(\.[a-zA-Z0-9._-]+)*$' "$clean_line"; or \
                       string match -q "inputs.*" "$clean_line"
                        set count (math $count + 1)
                    end
                end
            end
        end
    end < "$config_file"

    echo $count
end

function _nixpkg_list_simple -d "Simple package listing without headers"
    set -l config_file $argv[1]
    set -l package_section $argv[2]

    if not test -f "$config_file"
        echo "   ❌ File not found"
        return 1
    end

    set -l in_packages false
    set -l brace_count 0
    set -l in_shell_script false
    set -l found_any false

    # Check if this is a function-style file (like home-packages.nix)
    set -l is_function_file false
    if string match -q "*home-packages.nix" $config_file
        set is_function_file true
    end

    while read -l line
        # Check for shell script start and skip entire script
        if string match -q "*writeShellScriptBin*" $line
            set in_shell_script true
            continue
        end

        # Skip lines while in shell script until we find the end
        if test $in_shell_script = true
            if string match -q "*'')*" $line
                set in_shell_script false
            end
            continue
        end

        # Look for different package section patterns
        if string match -q "*$package_section = with pkgs; \[*" $line
            set in_packages true
            set brace_count 1
            continue
        else if string match -q "*$package_section = with pkgs; [*" $line
            set in_packages true
            set brace_count 1
            continue
        else if string match -q "*$package_section = import*" $line
            # Handle import-style package definitions
            echo "   ℹ️  Packages imported from external file"
            return 0
        else if test $is_function_file = true; and string match -q "*with pkgs; [*" $line
            # Handle function-style package files (home-packages.nix)
            set in_packages true
            set brace_count 1
            continue
        end

        # Handle package list extraction
        if test $in_packages = true
            # Count brackets for nested structures
            set brace_count (math $brace_count + (string length (string replace -a -r '[^\[]' '' $line)))
            set brace_count (math $brace_count - (string length (string replace -a -r '[^\]]' '' $line)))

            # Check if we're exiting the packages section
            if test $brace_count -le 0; and string match -q "*]*" $line
                set in_packages false
                continue
            end

            # Extract and validate package names
            set clean_line (string trim $line)
            set clean_line (string replace -r '#.*$' '' $clean_line)

            # Skip empty lines, comments, and lines with only punctuation
            if test -n "$clean_line"; and not string match -q -r '^\s*[\[\],;]+\s*$' "$clean_line"
                # Skip comment-only lines
                if not string match -q -r '^\s*#' "$clean_line"
                    # Clean up package names
                    set clean_line (string trim $clean_line)
                    set clean_line (string replace -r '[\s,;]*$' '' $clean_line)
                    # Only accept simple package names
                    if test -n "$clean_line"; and \
                       string match -q -r '^[a-zA-Z0-9._-]+(\.[a-zA-Z0-9._-]+)*$' "$clean_line"; or \
                       string match -q "inputs.*" "$clean_line"
                        echo "   • $clean_line"
                        set found_any true
                    end
                end
            end
        end
    end < "$config_file"

    if test $found_any = false
        echo "   (no packages found)"
    end
end

function _nixpkg_list -d "List packages in configuration file"
    set -l config_file    $argv[1]
    set -l package_section $argv[2]
    set -l target         $argv[3]
    set -l home_file_spec $argv[4]

    if not test -f "$config_file"
        echo "❌ Error: Configuration file not found: $config_file"
        return 1
    end

    if test -n "$home_file_spec"
        echo "📦 Listing packages in home-$home_file_spec.nix:"
    else
        echo "📦 Listing packages in $target configuration:"
    end
    echo "    File: $config_file"
    echo ""

    # Handle different file structures
    set -l count 0
    set -l in_packages false
    set -l brace_count 0
    set -l in_shell_script false

    # Check if this is a function-style file (like home-packages.nix)
    set -l is_function_file false
    if string match -q "*home-packages.nix" $config_file
        set is_function_file true
    end

    while read -l line
        # Check for shell script start and skip entire script
        if string match -q "*writeShellScriptBin*" $line
            set in_shell_script true
            continue
        end

        # Skip lines while in shell script until we find the end
        if test $in_shell_script = true
            if string match -q "*'')*" $line
                set in_shell_script false
            end
            continue
        end

        # Look for different package section patterns
        if string match -q "*$package_section = with pkgs; \[*" $line
            set in_packages true
            set brace_count 1
            continue
        else if string match -q "*$package_section = with pkgs; [*" $line
            set in_packages true
            set brace_count 1
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
        else if test $is_function_file = true; and string match -q "*with pkgs; [*" $line
            # Handle function-style package files (home-packages.nix)
            set in_packages true
            set brace_count 1
            continue
        end

        # Handle package list extraction
        if test $in_packages = true
            # Count brackets for nested structures
            set brace_count (math $brace_count + (string length (string replace -a -r '[^\[]' '' $line)))
            set brace_count (math $brace_count - (string length (string replace -a -r '[^\]]' '' $line)))

            # Check if we're exiting the packages section
            if test $brace_count -le 0; and string match -q "*]*" $line
                set in_packages false
                continue
            end

            # Extract and validate package names
            set clean_line (string trim $line)
            set clean_line (string replace -r '#.*$' '' $clean_line)

            # Skip empty lines, comments, and lines with only punctuation
            if test -n "$clean_line"; and not string match -q -r '^\s*[\[\],;]+\s*$' "$clean_line"
                # Skip comment-only lines
                if not string match -q -r '^\s*#' "$clean_line"
                    # Clean up package names
                    set clean_line (string trim $clean_line)
                    set clean_line (string replace -r '[\s,;]*$' '' $clean_line)
                    # Only accept simple package names
                    if test -n "$clean_line"; and \
                       string match -q -r '^[a-zA-Z0-9._-]+(\.[a-zA-Z0-9._-]+)*$' "$clean_line"; or \
                       string match -q "inputs.*" "$clean_line"
                        set count (math $count + 1)
                        echo "  • $clean_line"
                    end
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

    echo "  📦 Packages from imported file:"
    while read -l line
        set clean_line (string trim $line | string replace -r '#.*$' '')
        if test -n "$clean_line"; and not string match -q -r '^\s*[\[\],;{}]+\s*$' "$clean_line"
            if not string match -q -r '^\s*#' "$clean_line"; and \
               not string match -q -r '^\s*(with|pkgs|inputs|system)\s*$' "$clean_line"
                set clean_line (string replace -r '\s*#.*$' '' $clean_line)
                set clean_line (string trim $clean_line)
                set clean_line (string replace -r '[\s,;]*$' '' $clean_line)
                if test -n "$clean_line"
                    echo "    • $clean_line"
                end
            end
        end
    end < "$import_file"
end

function _nixpkg_add -d "Add package to configuration file (appends to the list)"
    set -l config_file    $argv[1]
    set -l package_section $argv[2]
    set -l package_name   $argv[3]
    set -l target         $argv[4]
    set -l home_file_spec $argv[5]

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
        if test -n "$home_file_spec"
            echo "⚠️ Package '$package_name' already exists in home-$home_file_spec.nix."
        else
            echo "⚠️ Package '$package_name' already exists in $target configuration."
        end
        return 1
    end

    if test -n "$home_file_spec"
        echo "➕ Adding '$package_name' to home-$home_file_spec.nix..."
    else
        echo "➕ Adding '$package_name' to $target configuration..."
    end
    echo "    File: $config_file"

    # Create backup
    cp "$config_file" "$config_file.bak"

    # Handle different file structures
    set -l temp_file  (mktemp)
    set -l added      false
    set -l in_packages false
    set -l brace_count 0
    set -l in_shell_script false

    while read -l line
        # Check for shell script start and skip insertion in shell scripts
        if string match -q "*writeShellScriptBin*" $line
            set in_shell_script true
        end

        # Check if we're exiting shell script - look for the closing of the script
        if test $in_shell_script = true
            if string match -q "*'')*" $line; or string match -q "*'');*" $line
                set in_shell_script false
            end
        end

        # Check for different package section patterns
        if string match -q "*$package_section = with pkgs; \[*" $line
            set in_packages true
            set brace_count 1
            echo $line >> "$temp_file"
            continue
        else if string match -q "*$package_section = with pkgs; [*" $line
            set in_packages true
            set brace_count 1
            echo $line >> "$temp_file"
            continue
        else if string match -q "*with pkgs; [*" $line
            # Handle function-style package files (home-packages.nix)
            set in_packages true
            set brace_count 1
            echo $line >> "$temp_file"
            continue
        end

        # Handle package list processing
        if test $in_packages = true
            # Count braces for nested structures
            set brace_count (math $brace_count + (string length (string replace -a -r '[^\[]' '' $line)))
            set brace_count (math $brace_count - (string length (string replace -a -r '[^\]]' '' $line)))

            # Check if we're at the end of the packages section
            if test $brace_count -le 0; and string match -q "*]*" $line
                if test $added = false
                    echo "    $package_name" >> "$temp_file"
                    set added true
                end
                set in_packages false
                echo $line >> "$temp_file"
                continue
            end

            # Add package before shell script - find last simple package before complex structures
            if test $added = false; and test $in_shell_script = false
                # Look for simple package lines that are good insertion points
                if string match -q -r '^\s*[a-zA-Z0-9._-]+(\.[a-zA-Z0-9._-]+)*\s*(#.*)?$' $line
                    # This is a simple package line - good place to insert after
                    echo $line >> "$temp_file"
                    echo "    $package_name" >> "$temp_file"
                    set added true
                    continue
                end
            end

            # Skip adding inside shell scripts
            if test $in_shell_script = true
                echo $line >> "$temp_file"
                continue
            end
        end

        echo $line >> "$temp_file"
    end < "$config_file"

    # Replace original file with modified version
    mv "$temp_file" "$config_file"

    if test $added = true
        echo "✅ Successfully added '$package_name'"
        echo "💾 Backup created: $config_file.bak"
    else
        echo "❌ Failed to add package (package section not found)"
        mv "$config_file.bak" "$config_file"  # Restore backup
        return 1
    end
end

function _nixpkg_remove -d "Remove package from configuration file"
    set -l config_file    $argv[1]
    set -l package_section $argv[2]
    set -l package_name   $argv[3]
    set -l target         $argv[4]
    set -l home_file_spec $argv[5]

    if not test -f "$config_file"
        echo "❌ Error: Configuration file not found: $config_file"
        return 1
    end

    # Check if package exists
    set -l package_exists false
    while read -l line
        set clean_line (string trim (string replace -r '#.*$' '' $line))
        if test "$clean_line" = "$package_name"
            set package_exists true
            break
        end
    end < "$config_file"

    if test $package_exists = false
        if test -n "$home_file_spec"
            echo "⚠️ Package '$package_name' not found in home-$home_file_spec.nix."
        else
            echo "⚠️ Package '$package_name' not found in $target configuration."
        end
        return 1
    end

    if test -n "$home_file_spec"
        echo "➖ Removing '$package_name' from home-$home_file_spec.nix..."
    else
        echo "➖ Removing '$package_name' from $target configuration..."
    end
    echo "    File: $config_file"

    # Create backup
    cp "$config_file" "$config_file.bak"

    # Handle different file structures
    set -l temp_file  (mktemp)
    set -l removed    false
    set -l in_packages false
    set -l brace_count 0

    while read -l line
        # Check for different package section patterns
        if string match -q "*$package_section = with pkgs; \[*" $line
            set in_packages true
            set brace_count 1
            echo $line >> "$temp_file"
            continue
        else if string match -q "*$package_section = with pkgs; [*" $line
            set in_packages true
            set brace_count 1
            echo $line >> "$temp_file"
            continue
        else if string match -q "*with pkgs; [*" $line
            # Handle function-style package files (home-packages.nix)
            set in_packages true
            set brace_count 1
            echo $line >> "$temp_file"
            continue
        end

        # Handle package list processing
        if test $in_packages = true
            # Count braces for nested structures
            set brace_count (math $brace_count + (string length (string replace -a -r '[^\[]' '' $line)))
            set brace_count (math $brace_count - (string length (string replace -a -r '[^\]]' '' $line)))

            # Check if we're exiting the packages section
            if test $brace_count -le 0; and string match -q "*]*" $line
                set in_packages false
                echo $line >> "$temp_file"
                continue
            end

            # Check if this line contains the package to remove
            set clean_line (string trim (string replace -r '#.*$' '' $line))
            if test "$clean_line" = "$package_name"
                set removed true
                continue  # Skip this line
            end
        end

        echo $line >> "$temp_file"
    end < "$config_file"

    # Replace original file with modified version
    mv "$temp_file" "$config_file"

    if test $removed = true
        echo "✅ Successfully removed '$package_name'"
        echo "💾 Backup created: $config_file.bak"
    else
        echo "❌ Failed to remove package (package not found in structure)"
        mv "$config_file.bak" "$config_file"  # Restore backup
        return 1
    end
end

function _nixpkg_help -d "Show help for nixpkg function"
    echo "📦 nixpkg - NixOS Package Manager"
    echo "════════════════════════════════════════════════════════════"
    echo ""
    echo "🎯 DESCRIPTION:"
    echo "    Manage packages in your NixOS configuration files with intelligent file detection."
    echo "    Supports multi-file configurations including home-packages.nix and home-*.nix files."
    echo ""
    echo "⚙️  USAGE:"
    echo "    nixpkg <action> [package] [target] [file-spec] [options]"
    echo ""
    echo "📋 ACTIONS:"
    echo "    list, ls, l          List packages in configuration"
    echo "    add, a               Add a package to configuration"
    echo "    remove, rm, r        Remove a package from configuration"
    echo "    search, s, find      Search for packages in nixpkgs"
    echo "    files, f, info       Show which configuration files are being used"
    echo "    help, h, --help      Show this help message"
    echo "    manual, man, doc     Show detailed manual"
    echo ""
    echo "🎯 TARGETS & FILE SPECS:"
    echo "    home, h              Target home configuration (default)"
    echo "    system, sys, s       Target configuration.nix"
    echo "    all                  List packages from ALL home files (list only)"
    echo "    <name>               Target home-<name>.nix (e.g., theme, screenshot)"
    echo ""
    echo "🔧 OPTIONS:"
    echo "    --rebuild, -r        Rebuild system after making changes"
    echo "    --fast, --skip       Rebuild system and skip git operations"
    echo ""
    echo "💡 EXAMPLES:"
    echo "    nixpkg files                   # Show configuration file structure"
    echo "    nixpkg list                    # List packages from primary home file"
    echo "    nixpkg list all                # List packages from ALL home files"
    echo "    nixpkg list theme              # List packages from home-theme.nix"
    echo "    nixpkg add firefox             # Add to primary home file"
    echo "    nixpkg add firefox theme       # Add to home-theme.nix"
    echo "    nixpkg add vim system -r       # Add vim to system and rebuild"
    echo "    nixpkg add firefox theme --fast # Add to theme and rebuild (skip git)"
    echo "    nixpkg remove htop screenshot  # Remove from home-screenshot.nix"
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
    echo "    and supports targeting specific home-*.nix files for modular package management."
    echo ""
    echo "📂 FILE TARGETS & STRUCTURE:"
    echo ""
    echo "    🖥️  SYSTEM TARGET (configuration.nix):"
    echo "      - File: \$NIXOS_CONFIG_DIR/configuration.nix"
    echo "      - Section: environment.systemPackages = with pkgs; ["
    echo "      - Scope: System-wide packages for all users"
    echo ""
    echo "    🏠 HOME TARGET FILES:"
    echo "      1. home-packages.nix (DEFAULT PRIORITY)"
    echo "         - File: \$NIXOS_CONFIG_DIR/home-packages.nix"
    echo "         - Section: home.packages = with pkgs; ["
    echo "         - Purpose: Primary user package management"
    echo ""
    echo "      2. Specific home-*.nix files (TARGETED ACCESS)"
    echo "         - Files: home-theme.nix, home-screenshot.nix, etc."
    echo "         - Section: home.packages = with pkgs; ["
    echo "         - Purpose: Modular, category-specific package management"
    echo "         - Access: Use file spec (e.g., 'theme' for home-theme.nix)"
    echo ""
    echo "      3. home.nix (FALLBACK)"
    echo "         - File: \$NIXOS_CONFIG_DIR/home.nix"
    echo "         - Section: home.packages = with pkgs; ["
    echo "         - Used when no other home files exist"
    echo ""
    echo "🛠️  ENHANCED ACTIONS:"
    echo ""
    echo "    📋 LIST (list, ls, l):"
    echo "        Standard: nixpkg list [target]     # List from primary file"
    echo "        All:      nixpkg list all         # List from ALL home files"
    echo "        Specific: nixpkg list <name>      # List from home-<name>.nix"
    echo "        Examples:"
    echo "          nixpkg list                     # Primary home file"
    echo "          nixpkg list all                 # All home files with counts"
    echo "          nixpkg list theme               # home-theme.nix only"
    echo "          nixpkg list screenshot          # home-screenshot.nix only"
    echo ""
    echo "    ➕ ADD (add, a):"
    echo "        Standard: nixpkg add <pkg> [target]      # Add to primary file"
    echo "        Specific: nixpkg add <pkg> <name>        # Add to home-<name>.nix"
    echo "        Examples:"
    echo "          nixpkg add firefox               # Add to primary home file"
    echo "          nixpkg add firefox theme         # Add to home-theme.nix"
    echo "          nixpkg add flameshot screenshot  # Add to home-screenshot.nix"
    echo ""
    echo "    ➖ REMOVE (remove, rm, r):"
    echo "        Standard: nixpkg remove <pkg> [target]   # Remove from primary"
    echo "        Specific: nixpkg remove <pkg> <name>     # Remove from specific"
    echo "        Examples:"
    echo "          nixpkg remove htop               # Remove from primary"
    echo "          nixpkg remove htop theme         # Remove from home-theme.nix"
    echo ""
    echo "    📁 FILES (files, f, info):"
    echo "        Shows all available home-*.nix files with usage instructions"
    echo "        Displays priority order and file status"
    echo ""
    echo "🔧 MODULAR WORKFLOW EXAMPLES:"
    echo ""
    echo "    🎨 Theme Management:"
    echo "      nixpkg add gtk3 theme              # GUI theming"
    echo "      nixpkg add papirus-icon-theme theme"
    echo "      nixpkg list theme                  # Check theme packages"
    echo ""
    echo "    📸 Screenshot Tools:"
    echo "      nixpkg add flameshot screenshot    # Screenshot utility"
    echo "      nixpkg add imagemagick screenshot  # Image processing"
    echo "      nixpkg list screenshot             # Check screenshot tools"
    echo ""
    echo "    🛠️  Development Setup:"
    echo "      nixpkg add git system              # System-wide git"
    echo "      nixpkg add vscode dev               # IDE in home-dev.nix"
    echo "      nixpkg add nodejs dev               # Runtime in dev file"
    echo ""
    echo "💡 ADVANCED FEATURES:"
    echo "    • Automatic file creation for new home-*.nix specs"
    echo "    • Comprehensive package listing across all files"
    echo "    • Backup system with automatic restoration on failure"
    echo "    • Intelligent duplicate prevention"
    echo "    • Cross-file package search and management"
    echo ""
    echo "🆘 TROUBLESHOOTING:"
    echo "    • Use 'nixpkg files' to see available home-*.nix files"
    echo "    • Use 'nixpkg list all' to see packages across all files"
    echo "    • Check file permissions in \$NIXOS_CONFIG_DIR"
    echo "    • Backup files (.bak) are created for safety"
    echo ""
    echo "ℹ️  For quick reference, use: nixpkg help"
end
