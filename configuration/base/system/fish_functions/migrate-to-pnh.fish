# migrate-to-pnh.fish
#
# Purpose: Migrate from nixos-shimboot to popcat19-nixos-hm as primary config
#
# This script:
# - Detects if nixos-config is nixos-shimboot
# - Renames to nixos-shimboot with timestamp backup
# - Clones popcat19-nixos-hm as new nixos-config
# - Updates NIXOS_CONFIG_DIR if needed
#
# Usage: migrate-to-pnh [--dry-run]
#
# Exit codes:
#   0 - Success
#   1 - Already migrated (nixos-config is pnh)
#   2 - nixos-config not found or is neither repo
#   3 - Clone failed

function migrate-to-pnh --argument dry_run
    set -l timestamp (date +%Y%m%d-%H%M%S)
    set -l config_dir "$HOME/nixos-config"
    set -l shimboot_dir "$HOME/nixos-shimboot"
    set -l pnh_repo "https://github.com/PopCat19/popcat19-nixos-hm.git"
    set -l pnh_branch "dev"

    # Check current nixos-config
    if not test -d "$config_dir"
        echo "[ERROR] $config_dir does not exist"
        return 2
    end

    # Check if nixos-config is already pnh
    if test -f "$config_dir/.git/config"
        set -l remote_url (git -C "$config_dir" remote get-url origin 2>/dev/null)
        if string match -q "*popcat19-nixos-hm*" $remote_url
            echo "[OK] nixos-config is already popcat19-nixos-hm"
            return 0
        end
    end

    # Check if nixos-config is nixos-shimboot
    set -l is_shimboot false
    if test -f "$config_dir/flake.nix"
        if grep -q "shimboot" "$config_dir/flake.nix" 2>/dev/null
            set is_shimboot true
        end
    end

    # Check for nixos-shimboot directory
    set -l shimboot_exists false
    if test -d "$shimboot_dir"
        set shimboot_exists true
    end

    # Plan the migration
    echo "[PLAN] Current state:"
    echo "  - nixos-config: $config_dir"
    echo "  - nixos-shimboot exists: $shimboot_exists"
    echo "  - Detected as shimboot: $is_shimboot"
    echo ""

    if test "$dry_run" = "--dry-run"
        echo "[DRY-RUN] Would perform:"
        if test "$is_shimboot" = true
            echo "  1. Rename $config_dir -> $config_dir-backup-$timestamp"
            if test "$shimboot_exists" = true
                echo "  2. Skip creating nixos-shimboot (already exists)"
            else
                echo "  2. Symlink nixos-shimboot -> $config_dir-backup-$timestamp"
            end
            echo "  3. Clone $pnh_repo (branch: $pnh_branch) -> $config_dir"
        else
            echo "  1. Rename $config_dir -> $config_dir-backup-$timestamp"
            echo "  2. Clone $pnh_repo (branch: $pnh_branch) -> $config_dir"
        end
        return 0
    end

    # Perform migration
    set -l backup_name "$config_dir-backup-$timestamp"

    echo "[STEP] Backing up current nixos-config..."
    if not mv "$config_dir" "$backup_name"
        echo "[ERROR] Failed to rename $config_dir"
        return 2
    end
    echo "[OK] Backed up to: $backup_name"

    # Create nixos-shimboot symlink if it doesn't exist
    if test "$shimboot_exists" = false
        echo "[STEP] Creating nixos-shimboot symlink..."
        ln -s "$backup_name" "$shimboot_dir"
        echo "[OK] Created: $shimboot_dir -> $backup_name"
    end

    # Clone pnh
    echo "[STEP] Cloning popcat19-nixos-hm..."
    if not git clone -b "$pnh_branch" "$pnh_repo" "$config_dir"
        echo "[ERROR] Failed to clone. Restoring backup..."
        mv "$backup_name" "$config_dir"
        return 3
    end
    echo "[OK] Cloned to: $config_dir"

    # Update NIXOS_CONFIG_DIR in fish if needed
    if set -q NIXOS_CONFIG_DIR
        if test "$NIXOS_CONFIG_DIR" != "$config_dir"
            echo ""
            echo "[INFO] NIXOS_CONFIG_DIR is set to: $NIXOS_CONFIG_DIR"
            echo "[INFO] You may need to update your shell config to point to: $config_dir"
            echo "[INFO] Or run: set -gx NIXOS_CONFIG_DIR $config_dir"
        end
    end

    echo ""
    echo "[SUCCESS] Migration complete!"
    echo "  - Old config: $backup_name"
    echo "  - New config: $config_dir"
    echo "  - Shimboot symlink: $shimboot_dir"
    echo ""
    echo "[NEXT] Run: cd $config_dir && nrb --dry-run"

    return 0
end