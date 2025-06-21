# Shared utilities for NixOS configuration management
# Common functions used by nixpkg and nixos-apply-config

function nixos_find_config_file -d "Find the primary NixOS configuration file"
    # Priority order: home-packages.nix > other home-*.nix > home.nix > configuration.nix
    set -l config_dir $NIXOS_CONFIG_DIR

    # Check for home-packages.nix first (highest priority for packages)
    if test -f "$config_dir/home-packages.nix"
        echo "$config_dir/home-packages.nix"
        return 0
    end

    # Check for other home-*.nix files
    for file in $config_dir/home-*.nix
        if test -f "$file"
            echo "$file"
            return 0
        end
    end

    # Fall back to home.nix
    if test -f "$config_dir/home.nix"
        echo "$config_dir/home.nix"
        return 0
    end

    # Last resort: configuration.nix
    if test -f "$config_dir/configuration.nix"
        echo "$config_dir/configuration.nix"
        return 0
    end

    return 1
end

function nixos_list_config_files -d "List all available NixOS configuration files"
    set -l config_dir $NIXOS_CONFIG_DIR

    echo "Available configuration files:"
    for file in $config_dir/home*.nix $config_dir/configuration.nix
        if test -f "$file"
            set -l basename (basename "$file")
            if test "$file" = (nixos_find_config_file)
                echo "  $basename (primary)"
            else
                echo "  $basename"
            end
        end
    end
end

function nixos_test_config -d "Test NixOS configuration with dry-run"
    set -l config_dir $NIXOS_CONFIG_DIR
    set -l hostname $NIXOS_FLAKE_HOSTNAME

    echo "🔍 Testing configuration..."
    cd "$config_dir"

    if sudo nixos-rebuild dry-run --flake "$config_dir#$hostname" 2>/dev/null
        echo "✅ Configuration test passed"
        return 0
    else
        echo "❌ Configuration test failed"
        return 1
    end
end

function nixos_backup_config -d "Create a backup of configuration files"
    set -l config_dir $NIXOS_CONFIG_DIR
    set -l backup_dir "$config_dir/.backups"
    set -l timestamp (date +%Y%m%d_%H%M%S)
    set -l backup_path "$backup_dir/config_$timestamp"

    mkdir -p "$backup_dir"
    cp -r "$config_dir"/*.nix "$backup_path" 2>/dev/null || begin
        mkdir -p "$backup_path"
        for file in $config_dir/*.nix
            if test -f "$file"
                cp "$file" "$backup_path/"
            end
        end
    end

    echo "📦 Backup created: $backup_path"
    echo "$backup_path"
end

function nixos_restore_config -d "Restore configuration from backup"
    set -l backup_path $argv[1]
    set -l config_dir $NIXOS_CONFIG_DIR

    if test -z "$backup_path"
        echo "❌ No backup path specified"
        return 1
    end

    if not test -d "$backup_path"
        echo "❌ Backup directory not found: $backup_path"
        return 1
    end

    echo "🔄 Restoring configuration from backup..."
    cp "$backup_path"/*.nix "$config_dir/"
    echo "✅ Configuration restored"
end

function nixos_git_status -d "Check git status of NixOS config"
    set -l config_dir $NIXOS_CONFIG_DIR
    cd "$config_dir"

    if not git rev-parse --git-dir >/dev/null 2>&1
        echo "⚠️  Not a git repository"
        return 1
    end

    set -l status (git status --porcelain)
    if test -z "$status"
        echo "✅ No changes in git repository"
        return 0
    else
        echo "📝 Git status:"
        git status --short
        return 0
    end
end

function nixos_git_commit -d "Commit changes to NixOS config"
    set -l commit_msg $argv[1]
    set -l config_dir $NIXOS_CONFIG_DIR

    if test -z "$commit_msg"
        echo "❌ No commit message provided"
        return 1
    end

    cd "$config_dir"

    # Add all changes
    git add .

    # Check if there are changes to commit
    if git diff --cached --quiet
        echo "ℹ️  No changes to commit"
        return 0
    end

    # Commit changes
    if git commit -m "$commit_msg"
        echo "✅ Changes committed: $commit_msg"

        # Push to remote if available
        if git remote | grep -q origin
            echo "📤 Pushing to remote..."
            if git push origin 2>/dev/null
                echo "✅ Pushed to remote"
            else
                echo "⚠️  Failed to push to remote"
            end
        end

        return 0
    else
        echo "❌ Failed to commit changes"
        return 1
    end
end

function nixos_current_generation -d "Get current NixOS generation number"
    nixos-rebuild list-generations | tail -1 | awk '{print $1}'
end

function nixos_list_generations -d "List recent NixOS generations"
    set -l count $argv[1]
    if test -z "$count"
        set count 5
    end

    echo "Recent NixOS generations:"
    nixos-rebuild list-generations | tail -$count
end

function nixos_rollback -d "Rollback to previous generation"
    set -l current_gen (nixos_current_generation)
    echo "🔄 Rolling back from generation $current_gen..."

    if sudo nixos-rebuild switch --rollback
        set -l new_gen (nixos_current_generation)
        echo "✅ Rolled back to generation $new_gen"
    else
        echo "❌ Rollback failed"
        return 1
    end
end

function nixos_package_exists -d "Check if a package exists in nixpkgs"
    set -l package $argv[1]

    if test -z "$package"
        return 1
    end

    # Quick check using nix search
    nix search nixpkgs "^$package\$" --json 2>/dev/null | grep -q "legacyPackages"
end

function nixos_find_package_section -d "Find the appropriate package section in config file"
    set -l config_file $argv[1]

    if test -z "$config_file"; or not test -f "$config_file"
        return 1
    end

    # Check for home.packages first
    if grep -q "home\.packages" "$config_file"
        echo "home.packages"
        return 0
    end

    # Check for environment.systemPackages
    if grep -q "environment\.systemPackages" "$config_file"
        echo "environment.systemPackages"
        return 0
    end

    return 1
end

function nixos_validate_environment -d "Validate required environment variables"
    set -l missing_vars

    if test -z "$NIXOS_CONFIG_DIR"
        set -a missing_vars "NIXOS_CONFIG_DIR"
    end

    if test -z "$NIXOS_FLAKE_HOSTNAME"
        set -a missing_vars "NIXOS_FLAKE_HOSTNAME"
    end

    if test (count $missing_vars) -gt 0
        echo "❌ Missing required environment variables:"
        for var in $missing_vars
            echo "  $var"
        end
        echo ""
        echo "💡 Set these variables in your shell configuration:"
        echo "  export NIXOS_CONFIG_DIR=\"/path/to/nixos-config\""
        echo "  export NIXOS_FLAKE_HOSTNAME=\"your-hostname\""
        return 1
    end

    if not test -d "$NIXOS_CONFIG_DIR"
        echo "❌ NIXOS_CONFIG_DIR does not exist: $NIXOS_CONFIG_DIR"
        return 1
    end

    return 0
end

function nixos_format_duration -d "Format duration in seconds to human readable"
    set -l seconds $argv[1]

    if test -z "$seconds"
        echo "0s"
        return
    end

    set -l minutes (math "$seconds / 60")
    set -l remaining_seconds (math "$seconds % 60")

    if test $minutes -gt 0
        echo "$minutes"m "$remaining_seconds"s
    else
        echo "$seconds"s
    end
end

function nixos_show_summary -d "Show system summary"
    echo "🖥️  NixOS System Summary"
    echo "  Config: $NIXOS_CONFIG_DIR"
    echo "  Host: $NIXOS_FLAKE_HOSTNAME"
    echo "  Generation: $(nixos_current_generation)"
    echo "  Primary config: $(basename (nixos_find_config_file))"
    nixos_git_status
end
