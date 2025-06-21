# Simplified NixOS Package Manager
# Usage: nixpkg <action> [package] [flags]
# Actions: add, remove, list, search, files
# Flags: -d (dry-run), -m "msg" (commit), -f (fast), -h (help)

function nixpkg -d "Simple NixOS package manager"
    # Handle no args or help
    if test (count $argv) -eq 0; or contains -- $argv[1] help h --help -h
        _nixpkg_help_simple
        return 0
    end

    # Parse action and package
    set -l action $argv[1]
    set -l package ""
    if test (count $argv) -gt 1
        set package $argv[2]
    end

    # Parse flags
    set -l dry_run false
    set -l commit_msg ""
    set -l fast_mode false

    for i in (seq 3 (count $argv))
        switch $argv[$i]
            case -d --dry
                set dry_run true
            case -m --message
                if test $i -lt (count $argv)
                    set commit_msg $argv[(math $i + 1)]
                end
            case -f --fast
                set fast_mode true
        end
    end

    # Execute action
    switch $action
        case add a
            _nixpkg_add_simple $package $dry_run $commit_msg $fast_mode
        case remove rm r
            _nixpkg_remove_simple $package $dry_run $commit_msg $fast_mode
        case list ls l
            _nixpkg_list_simple $package
        case search s
            _nixpkg_search_simple $package
        case files f
            _nixpkg_files_simple
        case '*'
            echo "❌ Unknown action: $action"
            _nixpkg_help_simple
            return 1
    end
end

function _nixpkg_add_simple -d "Add package with optional rebuild"
    set -l package $argv[1]
    set -l dry_run $argv[2]
    set -l commit_msg $argv[3]
    set -l fast_mode $argv[4]

    if test -z "$package"
        echo "❌ No package specified"
        return 1
    end

    # Find config file
    set -l config_file (_nixpkg_find_config)
    if test -z "$config_file"
        echo "❌ No config file found"
        return 1
    end

    echo "📦 Adding $package to $config_file"

    # Add package to config
    if not _nixpkg_insert_package $config_file $package
        echo "❌ Failed to add package"
        return 1
    end

    # Handle rebuild
    if test "$dry_run" = true
        echo "🔍 Dry-run: Testing configuration..."
        if _nixpkg_test_config
            echo "✅ Configuration valid"
            if test -n "$commit_msg"
                echo "🚀 Applying changes..."
                _nixpkg_apply_config $commit_msg $fast_mode
            end
        else
            echo "❌ Configuration invalid, reverting..."
            git checkout -- $config_file
            return 1
        end
    else if test -n "$commit_msg"
        echo "🚀 Applying changes..."
        _nixpkg_apply_config $commit_msg $fast_mode
    else
        echo "✅ Package added (use -m 'msg' to rebuild)"
    end
end

function _nixpkg_remove_simple -d "Remove package with optional rebuild"
    set -l package $argv[1]
    set -l dry_run $argv[2]
    set -l commit_msg $argv[3]
    set -l fast_mode $argv[4]

    if test -z "$package"
        echo "❌ No package specified"
        return 1
    end

    # Find config file
    set -l config_file (_nixpkg_find_config)
    if test -z "$config_file"
        echo "❌ No config file found"
        return 1
    end

    echo "🗑️  Removing $package from $config_file"

    # Remove package from config
    if not _nixpkg_delete_package $config_file $package
        echo "❌ Package not found or failed to remove"
        return 1
    end

    # Handle rebuild (same logic as add)
    if test "$dry_run" = true
        echo "🔍 Dry-run: Testing configuration..."
        if _nixpkg_test_config
            echo "✅ Configuration valid"
            if test -n "$commit_msg"
                echo "🚀 Applying changes..."
                _nixpkg_apply_config $commit_msg $fast_mode
            end
        else
            echo "❌ Configuration invalid, reverting..."
            git checkout -- $config_file
            return 1
        end
    else if test -n "$commit_msg"
        echo "🚀 Applying changes..."
        _nixpkg_apply_config $commit_msg $fast_mode
    else
        echo "✅ Package removed (use -m 'msg' to rebuild)"
    end
end

function _nixpkg_list_simple -d "List packages in config"
    set -l filter $argv[1]
    set -l config_file (_nixpkg_find_config)

    if test -z "$config_file"
        echo "❌ No config file found"
        return 1
    end

    echo "📋 Packages in $(basename $config_file):"
    if test -n "$filter"
        grep -E "pkgs\." $config_file | grep $filter | sed 's/^\s*/  /'
    else
        grep -E "pkgs\." $config_file | sed 's/^\s*/  /'
    end
end

function _nixpkg_search_simple -d "Search nixpkgs"
    set -l query $argv[1]
    if test -z "$query"
        echo "❌ No search query specified"
        return 1
    end

    echo "🔍 Searching nixpkgs for: $query"
    nix search nixpkgs $query
end

function _nixpkg_files_simple -d "List available config files"
    echo "📁 Available config files:"
    for file in $NIXOS_CONFIG_DIR/home*.nix $NIXOS_CONFIG_DIR/configuration.nix
        if test -f $file
            echo "  $(basename $file)"
        end
    end
end

# Utility functions
function _nixpkg_find_config -d "Find primary config file"
    # Priority: home-packages.nix > other home-*.nix > home.nix > configuration.nix
    for file in $NIXOS_CONFIG_DIR/home-packages.nix \
                $NIXOS_CONFIG_DIR/home-*.nix \
                $NIXOS_CONFIG_DIR/home.nix \
                $NIXOS_CONFIG_DIR/configuration.nix
        if test -f $file
            echo $file
            return 0
        end
    end
end

function _nixpkg_insert_package -d "Insert package into config file"
    set -l config_file $argv[1]
    set -l package $argv[2]

    # Simple insertion logic - add to packages list
    # This is a simplified version, real implementation would need proper nix parsing
    if grep -q "home.packages" $config_file
        sed -i "/home\.packages.*\[/a\    pkgs.$package" $config_file
    else if grep -q "environment.systemPackages" $config_file
        sed -i "/environment\.systemPackages.*\[/a\    pkgs.$package" $config_file
    else
        echo "❌ Could not find package list in config"
        return 1
    end
end

function _nixpkg_delete_package -d "Remove package from config file"
    set -l config_file $argv[1]
    set -l package $argv[2]

    # Remove package line
    sed -i "/pkgs\.$package/d" $config_file
end

function _nixpkg_test_config -d "Test configuration with dry-run"
    sudo nixos-rebuild dry-run --flake "$NIXOS_CONFIG_DIR#$NIXOS_FLAKE_HOSTNAME" >/dev/null 2>&1
end

function _nixpkg_apply_config -d "Apply configuration changes"
    set -l commit_msg $argv[1]
    set -l fast_mode $argv[2]

    # Add changes to git
    cd $NIXOS_CONFIG_DIR
    git add .

    # Rebuild system
    if test "$fast_mode" = true
        sudo nixos-rebuild switch --flake "$NIXOS_CONFIG_DIR#$NIXOS_FLAKE_HOSTNAME"
    else
        nixos-apply-config-simple -m "$commit_msg"
    end
end

function _nixpkg_help_simple -d "Show help"
    echo "🔧 nixpkg - Simple NixOS Package Manager"
    echo ""
    echo "Usage:"
    echo "  nixpkg add <package> [-d] [-m 'commit message'] [-f]"
    echo "  nixpkg remove <package> [-d] [-m 'commit message'] [-f]"
    echo "  nixpkg list [filter]"
    echo "  nixpkg search <query>"
    echo "  nixpkg files"
    echo ""
    echo "Flags:"
    echo "  -d, --dry     Dry-run test before applying"
    echo "  -m, --message Commit message (triggers rebuild)"
    echo "  -f, --fast    Fast mode (skip some checks)"
    echo "  -h, --help    Show this help"
    echo ""
    echo "Examples:"
    echo "  nixpkg add firefox -m 'Add Firefox browser'"
    echo "  nixpkg remove htop -d"
    echo "  nixpkg list browser"
    echo "  nixpkg search editor"
end
