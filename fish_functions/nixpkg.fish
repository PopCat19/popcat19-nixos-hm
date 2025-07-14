# ~/nixos-config/fish_functions/nixpkg.fish
# Streamlined NixOS package management
# Simple interface for adding/removing packages from configuration

# Load core dependencies
set -l script_dir (dirname (status --current-filename))
source "$script_dir/nixos-env-core.fish"

function nixpkg -d "📦 Simple NixOS package manager (add, remove, list, search)"
    # Parse arguments
    set -l action ""
    set -l package ""
    set -l commit_msg ""
    set -l dry_run false
    set -l show_help false

    if test (count $argv) -eq 0
        set show_help true
    else
        set action $argv[1]
        if test "$action" = "help" -o "$action" = "-h" -o "$action" = "--help"
            set show_help true
        end
    end

    if test "$show_help" = true
        _nixpkg_help
        return 0
    end

    # Validate environment
    if not nixos_validate_env
        return 1
    end

    # Parse remaining arguments
    set -l i 2
    while test $i -le (count $argv)
        switch $argv[$i]
            case -d --dry --dry-run
                set dry_run true
            case -m --message
                if test $i -lt (count $argv)
                    set i (math $i + 1)
                    set commit_msg "$argv[$i]"
                else
                    echo "❌ -m flag requires a commit message"
                    return 1
                end
            case '*'
                if test -z "$package"
                    set package "$argv[$i]"
                else
                    echo "❌ Unknown argument: $argv[$i]"
                    return 1
                end
        end
        set i (math $i + 1)
    end

    # Execute action
    switch $action
        case add a
            _nixpkg_add "$package" "$commit_msg" "$dry_run"
        case remove rm r del
            _nixpkg_remove "$package" "$commit_msg" "$dry_run"
        case list ls l
            _nixpkg_list "$package"
        case search s find
            _nixpkg_search "$package"
        case show info
            _nixpkg_show "$package"
        case '*'
            echo "❌ Unknown action: $action"
            _nixpkg_help
            return 1
    end
end

function _nixpkg_add -d "Add package to configuration"
    set -l package "$argv[1]"
    set -l commit_msg "$argv[2]"
    set -l dry_run "$argv[3]"

    if test -z "$package"
        echo "❌ No package specified"
        echo "Usage: nixpkg add <package> [-m 'message'] [-d]"
        return 1
    end

    # Find config file
    set -l config_file (nixos_find_config)
    if test -z "$config_file"
        echo "❌ No configuration file found"
        return 1
    end

    echo "📦 Adding $package to $(basename $config_file)"

    # Check if package already exists
    if grep -q "pkgs\.$package" "$config_file"
        echo "ℹ️  Package $package already exists in configuration"
        return 0
    end

    # Add package to config
    if not _nixpkg_insert_package "$config_file" "$package"
        echo "❌ Failed to add package to configuration"
        return 1
    end

    # Handle dry run
    if test "$dry_run" = true
        echo "🔍 Testing configuration..."
        if nixos_test_config
            echo "✅ Configuration test passed"
            if test -n "$commit_msg"
                echo "🚀 Applying changes..."
                nixos-apply-config -m "$commit_msg"
            else
                echo "💡 Use -m 'message' to apply changes"
            end
        else
            echo "❌ Configuration test failed, reverting..."
            git checkout -- "$config_file" 2>/dev/null || echo "⚠️  Could not revert changes"
            return 1
        end
    else if test -n "$commit_msg"
        echo "🚀 Applying changes..."
        nixos-apply-config -m "$commit_msg"
    else
        echo "✅ Package added to configuration"
        echo "💡 Use 'nixos-apply-config' to rebuild system"
    end
end

function _nixpkg_remove -d "Remove package from configuration"
    set -l package "$argv[1]"
    set -l commit_msg "$argv[2]"
    set -l dry_run "$argv[3]"

    if test -z "$package"
        echo "❌ No package specified"
        echo "Usage: nixpkg remove <package> [-m 'message'] [-d]"
        return 1
    end

    # Find config file
    set -l config_file (nixos_find_config)
    if test -z "$config_file"
        echo "❌ No configuration file found"
        return 1
    end

    echo "🗑️  Removing $package from $(basename $config_file)"

    # Check if package exists (both with and without pkgs prefix)
    if not grep -q "pkgs\.$package" "$config_file"; and not grep -q "^\s*$package\b" "$config_file"
        echo "ℹ️  Package $package not found in configuration"
        return 0
    end

    # Remove package from config
    if not _nixpkg_delete_package "$config_file" "$package"
        echo "❌ Failed to remove package from configuration"
        return 1
    end

    # Handle dry run (same logic as add)
    if test "$dry_run" = true
        echo "🔍 Testing configuration..."
        if nixos_test_config
            echo "✅ Configuration test passed"
            if test -n "$commit_msg"
                echo "🚀 Applying changes..."
                nixos-apply-config -m "$commit_msg"
            else
                echo "💡 Use -m 'message' to apply changes"
            end
        else
            echo "❌ Configuration test failed, reverting..."
            git checkout -- "$config_file" 2>/dev/null || echo "⚠️  Could not revert changes"
            return 1
        end
    else if test -n "$commit_msg"
        echo "🚀 Applying changes..."
        nixos-apply-config -m "$commit_msg"
    else
        echo "✅ Package removed from configuration"
        echo "💡 Use 'nixos-apply-config' to rebuild system"
    end
end

function _nixpkg_list -d "List packages in configuration"
    set -l filter "$argv[1]"
    set -l config_file (nixos_find_config)

    if test -z "$config_file"
        echo "❌ No configuration file found"
        return 1
    end

    echo "📋 Packages in $(basename $config_file):"

    if test -n "$filter"
        grep -E "pkgs\." "$config_file" | grep -i "$filter" | sed 's/^\s*/  /' | sort
    else
        grep -E "pkgs\." "$config_file" | sed 's/^\s*/  /' | sort
    end
end

function _nixpkg_search -d "Search nixpkgs for packages"
    set -l query "$argv[1]"

    if test -z "$query"
        echo "❌ No search query specified"
        echo "Usage: nixpkg search <query>"
        return 1
    end

    echo "🔍 Searching nixpkgs for: $query"
    nix search nixpkgs "$query" 2>/dev/null || begin
        echo "❌ Search failed. Make sure nix flakes are enabled."
        return 1
    end
end

function _nixpkg_show -d "Show package information"
    set -l package "$argv[1]"

    if test -z "$package"
        echo "❌ No package specified"
        echo "Usage: nixpkg show <package>"
        return 1
    end

    echo "📦 Package information for: $package"
    nix eval "nixpkgs#$package.meta.description" 2>/dev/null || begin
        echo "❌ Package not found or meta information unavailable"
        return 1
    end
end

# Utility functions for package manipulation
function _nixpkg_insert_package -d "Insert package into config file"
    set -l config_file "$argv[1]"
    set -l package "$argv[2]"

    # Look for package lists in order of preference
    if grep -q "home\.packages.*with.*pkgs.*\[" "$config_file"
        # Home Manager with pkgs style
        sed -i "/home\.packages.*with.*pkgs.*\[/a\\    $package" "$config_file"
    else if grep -q "home\.packages.*\[" "$config_file"
        # Home Manager direct style
        sed -i "/home\.packages.*\[/a\\    pkgs.$package" "$config_file"
    else if grep -q "environment\.systemPackages.*with.*pkgs.*\[" "$config_file"
        # System packages with pkgs style
        sed -i "/environment\.systemPackages.*with.*pkgs.*\[/a\\    $package" "$config_file"
    else if grep -q "environment\.systemPackages.*\[" "$config_file"
        # System packages direct style
        sed -i "/environment\.systemPackages.*\[/a\\    pkgs.$package" "$config_file"
    else if grep -q "with pkgs; \[" "$config_file"
        # Package list starting with "with pkgs; [" (like home-packages.nix)
        sed -i "/with pkgs; \[/a\\  $package                              # Added by nixpkg" "$config_file"
    else if grep -q "^\s*\[" "$config_file" && grep -q "# " "$config_file"
        # Simple list format - insert after opening bracket
        sed -i "/^\s*\[/a\\  $package                              # Added by nixpkg" "$config_file"
    else
        echo "❌ Could not find suitable package list in configuration"
        echo "💡 Make sure you have either home.packages, environment.systemPackages, or a package list defined"
        echo "💡 Current file structure not recognized - manual addition required"
        return 1
    end

    return 0
end

function _nixpkg_delete_package -d "Remove package from config file"
    set -l config_file "$argv[1]"
    set -l package "$argv[2]"

    # Remove both with and without pkgs prefix, including comments
    sed -i "/^\s*pkgs\.$package\b.*\$/d" "$config_file"
    sed -i "/^\s*$package\b.*\$/d" "$config_file"

    return 0
end

function _nixpkg_help
    echo "📦 nixpkg - Simple NixOS Package Manager"
    echo ""
    echo "Usage:"
    echo "  nixpkg add <package> [-m 'message'] [-d]    # Add package"
    echo "  nixpkg remove <package> [-m 'message'] [-d] # Remove package"
    echo "  nixpkg list [filter]                        # List packages"
    echo "  nixpkg search <query>                       # Search nixpkgs"
    echo "  nixpkg show <package>                       # Show package info"
    echo "  nixpkg --help                               # Show this help"
    echo ""
    echo "Options:"
    echo "  -m, --message MSG    Commit message (triggers rebuild)"
    echo "  -d, --dry-run        Test configuration before applying"
    echo ""
    echo "Examples:"
    echo "  nixpkg add firefox                          # Add package"
    echo "  nixpkg add htop -m 'Add system monitor'     # Add and rebuild"
    echo "  nixpkg remove vim -d                        # Remove with test"
    echo "  nixpkg list editor                          # List editor packages"
    echo "  nixpkg search browser                       # Search for browsers"
    echo "  nixpkg show firefox                         # Show package details"
    echo ""
    echo "Package Management:"
    echo "  • Automatically finds your primary config file"
    echo "  • Supports both home.packages and environment.systemPackages"
    echo "  • Handles both 'with pkgs;' and 'pkgs.' prefix styles"
    echo "  • Validates configuration before applying changes"
    echo ""
    echo "Integration:"
    echo "  • Use -m flag to automatically rebuild after changes"
    echo "  • Use -d flag to test configuration validity first"
    echo "  • Works with your existing git workflow"
end
