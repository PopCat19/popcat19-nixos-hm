# ~/nixos-config/fish_functions/nixos-workflows.fish
# Convenience wrapper functions for common NixOS workflows
# These combine multiple operations for streamlined user experience

# Load core dependencies
set -l script_dir (dirname (status --current-filename))
source "$script_dir/nixos-core.fish"

function nixos-edit-rebuild -d "📝 Edit configuration.nix, then 🚀 rebuild"
    if contains -- --help $argv; or contains -- help $argv
        _nixos_edit_rebuild_help
        return 0
    end

    if not nixos_validate_env
        return 1
    end

    echo "📝 Opening configuration.nix for editing..."
    nixconf-edit

    if test $status -eq 0
        echo "🚀 Applying changes..."
        nixos-apply-config $argv
    else
        echo "❌ Edit was cancelled or failed"
        return 1
    end
end

function home-edit-rebuild -d "📝 Edit home.nix, then 🚀 rebuild"
    if contains -- --help $argv; or contains -- help $argv
        _home_edit_rebuild_help
        return 0
    end

    if not nixos_validate_env
        return 1
    end

    echo "📝 Opening home.nix for editing..."
    homeconf-edit

    if test $status -eq 0
        echo "🚀 Applying changes..."
        nixos-apply-config $argv
    else
        echo "❌ Edit was cancelled or failed"
        return 1
    end
end

function nixos-upgrade -d "🔄 Update flake inputs, then 🚀 rebuild"
    if contains -- --help $argv; or contains -- help $argv
        _nixos_upgrade_help
        return 0
    end

    if not nixos_validate_env
        return 1
    end

    echo "🔄 Starting NixOS upgrade (flake update + rebuild)..."

    # Update flake inputs
    if flake-update $argv[2..-1]
        echo "✅ Flake inputs updated successfully"

        # Apply configuration
        echo "🚀 Applying updated configuration..."
        nixos-apply-config $argv[1]
    else
        echo "❌ Upgrade failed during flake update"
        return 1
    end
end

function nixos-quick-commit -d "🚀 Quick rebuild and commit with message"
    if test (count $argv) -eq 0
        echo "❌ Usage: nixos-quick-commit 'commit message'"
        return 1
    end

    if contains -- --help $argv; or contains -- help $argv
        _nixos_quick_commit_help
        return 0
    end

    if not nixos_validate_env
        return 1
    end

    set -l commit_msg (string join " " $argv)

    echo "🚀 Quick commit workflow: rebuild + commit + push"

    # Test configuration first
    if not nixos_test_config
        echo "❌ Configuration test failed, aborting"
        return 1
    end

    # Apply with commit
    nixos-apply-config -m "$commit_msg"
end

function nixos-status -d "📊 Show comprehensive NixOS system status"
    if contains -- --help $argv; or contains -- help $argv
        _nixos_status_help
        return 0
    end

    if not nixos_validate_env
        return 1
    end

    nixos_show_summary

    echo ""
    echo "📋 Recent generations:"
    nixos-rebuild list-generations | tail -3

    echo ""
    echo "📦 Flake status:"
    if test -f "$NIXOS_CONFIG_DIR/flake.nix"
        if test -f "$NIXOS_CONFIG_DIR/flake.lock"
            echo "  ✅ Flake configuration active"
            if test -f "$NIXOS_CONFIG_DIR/flake.lock.bak"
                echo "  💾 Backup available: flake.lock.bak"
            end
        else
            echo "  ⚠️  Flake.nix exists but no lock file"
        end
    else
        echo "  ❌ No flake configuration found"
    end
end

function nixos-rollback -d "🔄 Rollback to previous generation"
    if contains -- --help $argv; or contains -- help $argv
        _nixos_rollback_help
        return 0
    end

    if not nixos_validate_env
        return 1
    end

    set -l current_gen (nixos_current_generation)
    echo "🔄 Rolling back from generation $current_gen..."

    if sudo nixos-rebuild switch --rollback
        set -l new_gen (nixos_current_generation)
        echo "✅ Rolled back to generation $new_gen"

        # Optionally commit the rollback
        if contains -- --commit $argv
            nixos-git "🔄 Rollback to generation $new_gen"
        end
    else
        echo "❌ Rollback failed"
        return 1
    end
end

# Help functions
function _nixos_edit_rebuild_help
    echo "📝 nixos-edit-rebuild - Edit and rebuild system configuration"
    echo ""
    echo "Usage:"
    echo "  nixos-edit-rebuild [nixos-apply-config options]"
    echo "  nixos-edit-rebuild --help"
    echo ""
    echo "Workflow:"
    echo "  1. Opens configuration.nix in \$EDITOR"
    echo "  2. After editing, calls nixos-apply-config"
    echo ""
    echo "Examples:"
    echo "  nixos-edit-rebuild"
    echo "  nixos-edit-rebuild -m 'Update system packages'"
end

function _home_edit_rebuild_help
    echo "📝 home-edit-rebuild - Edit and rebuild home configuration"
    echo ""
    echo "Usage:"
    echo "  home-edit-rebuild [nixos-apply-config options]"
    echo "  home-edit-rebuild --help"
    echo ""
    echo "Workflow:"
    echo "  1. Opens home.nix in \$EDITOR"
    echo "  2. After editing, calls nixos-apply-config"
    echo ""
    echo "Examples:"
    echo "  home-edit-rebuild"
    echo "  home-edit-rebuild -m 'Add user packages'"
end

function _nixos_upgrade_help
    echo "🔄 nixos-upgrade - Update and rebuild system"
    echo ""
    echo "Usage:"
    echo "  nixos-upgrade [nixos-apply-config options] [flake-update options]"
    echo "  nixos-upgrade --help"
    echo ""
    echo "Workflow:"
    echo "  1. Updates flake inputs"
    echo "  2. Rebuilds system with updated inputs"
    echo ""
    echo "Examples:"
    echo "  nixos-upgrade"
    echo "  nixos-upgrade -m 'Monthly system update'"
    echo "  nixos-upgrade nixpkgs  # Update only nixpkgs"
end

function _nixos_quick_commit_help
    echo "🚀 nixos-quick-commit - Quick rebuild and commit"
    echo ""
    echo "Usage:"
    echo "  nixos-quick-commit 'commit message'"
    echo "  nixos-quick-commit --help"
    echo ""
    echo "Workflow:"
    echo "  1. Tests configuration"
    echo "  2. Rebuilds system"
    echo "  3. Commits and pushes changes"
    echo ""
    echo "Examples:"
    echo "  nixos-quick-commit 'Add development tools'"
    echo "  nixos-quick-commit 'Fix audio configuration'"
end

function _nixos_status_help
    echo "📊 nixos-status - Show system status"
    echo ""
    echo "Usage:"
    echo "  nixos-status"
    echo "  nixos-status --help"
    echo ""
    echo "Shows:"
    echo "  • System configuration summary"
    echo "  • Git repository status"
    echo "  • Recent generations"
    echo "  • Flake status"
end

function _nixos_rollback_help
    echo "🔄 nixos-rollback - Rollback system"
    echo ""
    echo "Usage:"
    echo "  nixos-rollback [--commit]"
    echo "  nixos-rollback --help"
    echo ""
    echo "Options:"
    echo "  --commit    Commit the rollback to git"
    echo ""
    echo "Examples:"
    echo "  nixos-rollback           # Just rollback"
    echo "  nixos-rollback --commit  # Rollback and commit"
end
