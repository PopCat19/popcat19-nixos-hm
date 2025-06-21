# Simplified NixOS Configuration Applier
# Usage: nixos-apply-config-simple [flags]
# Flags: -d (dry-run), -m "msg" (commit), -f (fast), -h (help)

function nixos-apply-config-simple -d "Simple NixOS configuration applier"
    # Parse flags
    set -l dry_run false
    set -l commit_msg ""
    set -l fast_mode false

    # Handle no args or help
    if contains -- help $argv; or contains -- h $argv; or contains -- --help $argv; or contains -- -h $argv
        _nixos_apply_help_simple
        return 0
    end

    # Parse arguments
    set -l i 1
    while test $i -le (count $argv)
        switch $argv[$i]
            case -d --dry
                set dry_run true
            case -m --message
                if test $i -lt (count $argv)
                    set i (math $i + 1)
                    set commit_msg $argv[$i]
                else
                    echo "❌ Error: -m flag requires a commit message"
                    return 1
                end
            case -f --fast
                set fast_mode true
            case '*'
                echo "❌ Unknown flag: $argv[$i]"
                _nixos_apply_help_simple
                return 1
        end
        set i (math $i + 1)
    end

    # Execute based on mode
    if test "$dry_run" = true
        _nixos_apply_dry_run $commit_msg
    else
        _nixos_apply_rebuild $commit_msg $fast_mode
    end
end

function _nixos_apply_dry_run -d "Test configuration with dry-run"
    set -l commit_msg $argv[1]

    echo "🔍 Testing NixOS configuration..."

    # Ensure we're in the config directory
    cd $NIXOS_CONFIG_DIR

    # Test configuration
    if sudo nixos-rebuild dry-run --flake "$NIXOS_CONFIG_DIR#$NIXOS_FLAKE_HOSTNAME"
        echo "✅ Configuration test passed!"

        # If commit message provided, offer to apply
        if test -n "$commit_msg"
            echo "🚀 Auto-applying configuration..."
            _nixos_apply_rebuild $commit_msg false
        else
            echo "💡 Use -m 'message' to apply changes"
        end
    else
        echo "❌ Configuration test failed!"
        return 1
    end
end

function _nixos_apply_rebuild -d "Rebuild and apply configuration"
    set -l commit_msg $argv[1]
    set -l fast_mode $argv[2]

    echo "🚀 Applying NixOS configuration..."

    # Ensure we're in the config directory
    cd $NIXOS_CONFIG_DIR

    # Git operations (unless fast mode)
    if test "$fast_mode" != true
        echo "📝 Preparing git commit..."

        # Add all changes
        git add .

        # Check if there are changes to commit
        if git diff --cached --quiet
            echo "ℹ️  No changes to commit"
        else
            # Commit changes
            if test -n "$commit_msg"
                git commit -m "$commit_msg"
                echo "✅ Changes committed: $commit_msg"
            else
                echo "⚠️  Changes staged but no commit message provided"
            end
        end
    end

    # Create backup of current generation
    set -l current_gen (nixos-rebuild list-generations | tail -1 | awk '{print $1}')
    echo "📦 Current generation: $current_gen"

    # Rebuild system
    echo "🔧 Rebuilding NixOS..."
    if sudo nixos-rebuild switch --flake "$NIXOS_CONFIG_DIR#$NIXOS_FLAKE_HOSTNAME"
        echo "✅ NixOS rebuild successful!"

        # Show new generation
        set -l new_gen (nixos-rebuild list-generations | tail -1 | awk '{print $1}')
        echo "🎉 New generation: $new_gen"

        # Push to remote if git repo has origin
        if test "$fast_mode" != true; and git remote | grep -q origin
            echo "📤 Pushing to remote repository..."
            git push origin 2>/dev/null || echo "⚠️  Failed to push (continuing anyway)"
        end

    else
        echo "❌ NixOS rebuild failed!"
        echo "🔄 System remains on generation $current_gen"

        # Offer rollback option
        echo "💡 To rollback: sudo nixos-rebuild switch --rollback"
        return 1
    end
end

function _nixos_apply_help_simple -d "Show help"
    echo "🚀 nixos-apply-config-simple - Simple NixOS Configuration Applier"
    echo ""
    echo "Usage:"
    echo "  nixos-apply-config-simple [-d] [-m 'commit message'] [-f]"
    echo ""
    echo "Flags:"
    echo "  -d, --dry     Test configuration without applying"
    echo "  -m, --message Git commit message (enables git operations)"
    echo "  -f, --fast    Skip git operations and checks"
    echo "  -h, --help    Show this help"
    echo ""
    echo "Examples:"
    echo "  nixos-apply-config-simple -d"
    echo "  nixos-apply-config-simple -m 'Update system configuration'"
    echo "  nixos-apply-config-simple -f"
    echo "  nixos-apply-config-simple -d -m 'Test then apply changes'"
    echo ""
    echo "Workflow:"
    echo "  1. Dry-run: Test configuration validity"
    echo "  2. Git: Add, commit, and push changes (unless -f)"
    echo "  3. Rebuild: Apply configuration to system"
    echo "  4. Rollback: Available if rebuild fails"
end
