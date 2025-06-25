# ~/nixos-config/fish_functions/nixos-utils.fish
# Additional utilities for NixOS configuration management
# Extends the core utilities with specialized functions

# Load core dependencies
set -l script_dir (dirname (status --current-filename))
source "$script_dir/nixos-core.fish"

function nixos-info -d "📊 Show detailed system information"
    if not nixos_validate_env
        return 1
    end

    echo "🖥️  NixOS System Information"
    echo "═══════════════════════════════════════════════════════════"
    echo ""

    # Basic system info
    echo "📂 Configuration:"
    echo "  Directory: $NIXOS_CONFIG_DIR"
    echo "  Hostname: $NIXOS_FLAKE_HOSTNAME"

    # Current generation
    set -l current_gen (nixos_current_generation)
    echo "  Generation: $current_gen"

    # Primary config file
    set -l primary_config (nixos_find_config)
    if test -n "$primary_config"
        echo "  Primary config: $(basename $primary_config)"
    end

    echo ""

    # Git status
    echo "📝 Git Repository:"
    if nixos_git_check
        pushd "$NIXOS_CONFIG_DIR" >/dev/null
        set -l branch (git branch --show-current 2>/dev/null || echo "unknown")
        set -l commit (git rev-parse --short HEAD 2>/dev/null || echo "unknown")
        echo "  Branch: $branch"
        echo "  Commit: $commit"

        set -l status (git status --porcelain)
        if test -z "$status"
            echo "  Status: Clean"
        else
            echo "  Status: $(echo "$status" | wc -l) modified files"
        end

        if git remote | grep -q origin
            echo "  Remote: $(git remote get-url origin 2>/dev/null || echo 'configured')"
        else
            echo "  Remote: None"
        end
        popd >/dev/null
    else
        echo "  Status: Not a git repository"
    end

    echo ""

    # Flake status
    echo "📦 Flake Configuration:"
    if test -f "$NIXOS_CONFIG_DIR/flake.nix"
        echo "  Flake: Present"
        if test -f "$NIXOS_CONFIG_DIR/flake.lock"
            set -l lock_age (stat -c %Y "$NIXOS_CONFIG_DIR/flake.lock" 2>/dev/null || echo "0")
            set -l current_time (date +%s)
            set -l age_days (math "($current_time - $lock_age) / 86400")
            echo "  Lock file: $age_days days old"
        else
            echo "  Lock file: Missing"
        end

        if test -f "$NIXOS_CONFIG_DIR/flake.lock.bak"
            echo "  Backup: Available"
        else
            echo "  Backup: None"
        end
    else
        echo "  Flake: Not found"
    end

    echo ""

    # Recent generations
    echo "📋 Recent Generations:"
    nixos-rebuild list-generations 2>/dev/null | head -6 | tail -5 | while read line
        if echo "$line" | grep -q "current"
            echo "  → $line"
        else
            echo "    $line"
        end
    end
end

function nixos-doctor -d "🔧 Diagnose common NixOS configuration issues"
    if not nixos_validate_env
        return 1
    end

    echo "🔧 NixOS Configuration Diagnostics"
    echo "═══════════════════════════════════════════════════════════"
    echo ""

    set -l issues_found 0

    # Check environment variables
    echo "🔍 Checking environment variables..."
    if test -z "$NIXOS_CONFIG_DIR"
        echo "  ❌ NIXOS_CONFIG_DIR is not set"
        set issues_found (math $issues_found + 1)
    else if not test -d "$NIXOS_CONFIG_DIR"
        echo "  ❌ NIXOS_CONFIG_DIR directory does not exist: $NIXOS_CONFIG_DIR"
        set issues_found (math $issues_found + 1)
    else
        echo "  ✅ NIXOS_CONFIG_DIR is valid"
    end

    if test -z "$NIXOS_FLAKE_HOSTNAME"
        echo "  ❌ NIXOS_FLAKE_HOSTNAME is not set"
        set issues_found (math $issues_found + 1)
    else
        echo "  ✅ NIXOS_FLAKE_HOSTNAME is set"
    end

    # Check configuration files
    echo ""
    echo "🔍 Checking configuration files..."

    set -l config_found false
    for file in "$NIXOS_CONFIG_DIR"/home*.nix "$NIXOS_CONFIG_DIR/configuration.nix"
        if test -f "$file"
            echo "  ✅ Found: $(basename $file)"
            set config_found true
        end
    end

    if not test "$config_found" = true
        echo "  ❌ No configuration files found"
        set issues_found (math $issues_found + 1)
    end

    # Check flake configuration
    echo ""
    echo "🔍 Checking flake configuration..."
    if test -f "$NIXOS_CONFIG_DIR/flake.nix"
        echo "  ✅ flake.nix found"

        if test -f "$NIXOS_CONFIG_DIR/flake.lock"
            echo "  ✅ flake.lock found"
        else
            echo "  ⚠️  flake.lock missing (run 'flake-update')"
        end
    else
        echo "  ❌ flake.nix not found"
        set issues_found (math $issues_found + 1)
    end

    # Check git repository
    echo ""
    echo "🔍 Checking git repository..."
    if nixos_git_check
        echo "  ✅ Git repository initialized"

        pushd "$NIXOS_CONFIG_DIR" >/dev/null
        if git remote | grep -q origin
            echo "  ✅ Remote repository configured"
        else
            echo "  ⚠️  No remote repository (consider adding one)"
        end

        set -l untracked (git ls-files --others --exclude-standard | wc -l)
        if test "$untracked" -gt 0
            echo "  ⚠️  $untracked untracked files"
        end
        popd >/dev/null
    else
        echo "  ❌ Not a git repository (run 'git init')"
        set issues_found (math $issues_found + 1)
    end

    # Test configuration
    echo ""
    echo "🔍 Testing configuration..."
    if nixos_test_config
        echo "  ✅ Configuration is valid"
    else
        echo "  ❌ Configuration has errors"
        set issues_found (math $issues_found + 1)
    end

    # Summary
    echo ""
    echo "📊 Diagnostic Summary:"
    if test "$issues_found" -eq 0
        echo "  ✅ No issues found - system is healthy!"
    else
        echo "  ❌ Found $issues_found issue(s) that need attention"
        echo ""
        echo "💡 Recommendations:"
        echo "  • Fix the issues listed above"
        echo "  • Run 'nixos-doctor' again to verify fixes"
        echo "  • Use 'nixos-info' for detailed system information"
    end
end

function nixos-cleanup -d "🧹 Clean up temporary files and old generations"
    if not nixos_validate_env
        return 1
    end

    echo "🧹 NixOS Cleanup Utility"
    echo "═══════════════════════════════════════════════════════════"
    echo ""

    # Clean up backup files
    echo "🗑️  Cleaning backup files..."
    set -l backup_files "$NIXOS_CONFIG_DIR/flake.lock.bak"

    if test -f "$backup_files"
        rm "$backup_files"
        echo "  ✅ Removed flake.lock.bak"
    else
        echo "  ℹ️  No backup files to clean"
    end

    # Show old generations
    echo ""
    echo "📋 System generations:"
    set -l total_gens (nixos-rebuild list-generations | wc -l)
    echo "  Total generations: $total_gens"

    if test "$total_gens" -gt 5
        echo "  ⚠️  Consider cleaning old generations"
        echo "  💡 Use: sudo nix-collect-garbage -d"
        echo "  💡 Or: sudo nix-collect-garbage --delete-older-than 7d"
    else
        echo "  ✅ Generation count is reasonable"
    end

    # Check nix store
    echo ""
    echo "💾 Nix store information:"
    if command -q nix
        set -l store_size (nix path-info -S --closure-size /run/current-system 2>/dev/null | tail -1 | awk '{print $2}' | numfmt --to=iec-i --suffix=B 2>/dev/null || echo "unknown")
        echo "  Current system closure: $store_size"
    end

    echo ""
    echo "🔧 Manual cleanup commands:"
    echo "  • Clean old generations: sudo nix-collect-garbage -d"
    echo "  • Clean store: sudo nix-store --gc"
    echo "  • Optimize store: sudo nix-store --optimise"
end

function nixos-backup -d "💾 Backup current configuration"
    if not nixos_validate_env
        return 1
    end

    set -l timestamp (date +%Y%m%d_%H%M%S)
    set -l backup_dir "$HOME/.nixos-backups"
    set -l backup_path "$backup_dir/nixos-config-$timestamp"

    echo "💾 Creating configuration backup..."
    echo "  Backup location: $backup_path"

    # Create backup directory
    mkdir -p "$backup_dir"

    # Copy configuration files
    cp -r "$NIXOS_CONFIG_DIR" "$backup_path"

    # Create backup info file
    echo "# NixOS Configuration Backup" > "$backup_path/backup-info.txt"
    echo "Created: $(date)" >> "$backup_path/backup-info.txt"
    echo "Hostname: $NIXOS_FLAKE_HOSTNAME" >> "$backup_path/backup-info.txt"
    echo "Generation: $(nixos_current_generation)" >> "$backup_path/backup-info.txt"

    if nixos_git_check
        pushd "$NIXOS_CONFIG_DIR" >/dev/null
        echo "Git branch: $(git branch --show-current 2>/dev/null || echo 'unknown')" >> "$backup_path/backup-info.txt"
        echo "Git commit: $(git rev-parse HEAD 2>/dev/null || echo 'unknown')" >> "$backup_path/backup-info.txt"
        popd >/dev/null
    end

    echo "✅ Backup created successfully"
    echo "  Size: $(du -sh "$backup_path" | cut -f1)"
    echo "  Files: $(find "$backup_path" -type f | wc -l)"

    # Clean old backups (keep last 5)
    set -l old_backups (ls -1t "$backup_dir" | tail -n +6)
    if test (count $old_backups) -gt 0
        echo "🗑️  Cleaning old backups..."
        for old_backup in $old_backups
            rm -rf "$backup_dir/$old_backup"
            echo "  Removed: $old_backup"
        end
    end
end

function nixos-restore -d "🔄 Restore configuration from backup"
    set -l backup_dir "$HOME/.nixos-backups"

    if not test -d "$backup_dir"
        echo "❌ No backups found in $backup_dir"
        return 1
    end

    echo "💾 Available backups:"
    set -l backups (ls -1t "$backup_dir" 2>/dev/null)

    if test (count $backups) -eq 0
        echo "❌ No backups available"
        return 1
    end

    set -l i 1
    for backup in $backups
        echo "  $i) $backup"
        if test -f "$backup_dir/$backup/backup-info.txt"
            grep "Created:" "$backup_dir/$backup/backup-info.txt" | sed 's/^/     /'
        end
        set i (math $i + 1)
    end

    echo ""
    echo "Enter backup number to restore (1-$(count $backups)) or 'q' to quit:"
    read -p "set_color yellow; echo -n '> '; set_color normal" choice

    if test "$choice" = "q"
        echo "Restore cancelled"
        return 0
    end

    if not string match -rq '^\d+$' "$choice"; or test "$choice" -lt 1; or test "$choice" -gt (count $backups)
        echo "❌ Invalid selection"
        return 1
    end

    set -l selected_backup $backups[$choice]
    set -l backup_path "$backup_dir/$selected_backup"

    echo "🔄 Restoring from: $selected_backup"
    echo "⚠️  This will overwrite your current configuration!"
    echo "Continue? (y/N)"
    read -p "set_color yellow; echo -n '> '; set_color normal" confirm

    if test "$confirm" != "y" -a "$confirm" != "Y"
        echo "Restore cancelled"
        return 0
    end

    # Backup current config first
    echo "💾 Creating backup of current configuration..."
    nixos-backup >/dev/null

    # Restore from backup
    echo "🔄 Restoring configuration..."
    cp -r "$backup_path"/* "$NIXOS_CONFIG_DIR/"
    rm -f "$NIXOS_CONFIG_DIR/backup-info.txt"  # Remove backup info file

    echo "✅ Configuration restored successfully"
    echo "💡 Test with: nixos-apply-config -d"
end
