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
    
    # Set file paths - REMOVE the -l flag to make them global to this function
    if test "$target" = "system"
        set config_file "$NIXOS_CONFIG_DIR/configuration.nix"
        set package_section "environment.systemPackages"
    else
        set config_file "$NIXOS_CONFIG_DIR/home.nix"
        set package_section "home.packages"
    end
    
    # Debug output (remove after testing)
    echo "Debug: target=$target, config_file=$config_file, clean_args=$clean_args"
    
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
