# ~/nixos-config/fish_functions/nixos-apply-config.fish
# Streamlined NixOS configuration application
# Handles testing, rebuilding, and git operations

# Load core dependencies
set -l script_dir (dirname (status --current-filename))
source "$script_dir/nixos-env-core.fish"
source "$script_dir/nixos-system-core.fish"
source "$script_dir/nixos-utils-core.fish"
source "$script_dir/nixos-git-core.fish"

function nixos-apply-config -d "🚀 Apply NixOS configuration with optional git operations"
    # Parse arguments
    set -l dry_run false
    set -l commit_msg ""
    set -l auto_commit false
    set -l show_help false

    for arg in $argv
        switch $arg
            case -d --dry --dry-run
                set dry_run true
            case -c --commit
                set auto_commit true
            case -m --message
                # Next argument should be the message
                continue
            case -h --help help
                set show_help true
            case '*'
                # Check if this follows -m flag
                if test -n "$commit_msg"
                    # Already have a message, this is an unknown arg
                    echo "❌ Unknown argument: $arg"
                    _nixos_apply_help
                    return 1
                else
                    # This might be a commit message
                    set commit_msg "$arg"
                end
        end
    end

    # Handle message flag properly
    set -l i 1
    while test $i -le (count $argv)
        if test "$argv[$i]" = "-m"; or test "$argv[$i]" = "--message"
            if test $i -lt (count $argv)
                set i (math $i + 1)
                set commit_msg "$argv[$i]"
                set auto_commit true
            else
                echo "❌ -m flag requires a commit message"
                return 1
            end
        end
        set i (math $i + 1)
    end

    if test "$show_help" = true
        _nixos_apply_help
        return 0
    end

    # Validate environment
    if not nixos_validate_env
        return 1
    end

    # Dry run mode
    if test "$dry_run" = true
        echo "🔍 Testing configuration..."
        if nixos_test_config
            echo "✅ Configuration test passed"
            if test "$auto_commit" = true
                echo "🚀 Test passed, applying configuration..."
                _nixos_apply_full "$commit_msg"
            else
                echo "💡 Use without -d to apply changes"
            end
        else
            echo "❌ Configuration test failed"
            return 1
        end
        return 0
    end

    # Full application
    _nixos_apply_full "$commit_msg" "$auto_commit"
end

function _nixos_apply_full -d "Apply configuration with full rebuild"
    set -l commit_msg "$argv[1]"
    set -l auto_commit "$argv[2]"

    echo "🚀 Applying NixOS configuration..."

    # Git operations if requested
    if test "$auto_commit" = true -a -n "$commit_msg"
        echo "📝 Committing changes..."
        if not nixos_git_commit "$commit_msg"
            echo "⚠️  Git commit failed, continuing with rebuild..."
        end
    end

    # Rebuild system
    if nixos_rebuild
        echo "✅ Configuration applied successfully!"

        # Push to remote if we committed
        if test "$auto_commit" = true -a -n "$commit_msg"
            nixos_git_push
        end

        return 0
    else
        echo "❌ Configuration application failed"
        return 1
    end
end

function _nixos_apply_help
    echo "🚀 nixos-apply-config - Apply NixOS Configuration"
    echo ""
    echo "Usage:"
    echo "  nixos-apply-config [options]"
    echo ""
    echo "Options:"
    echo "  -d, --dry-run        Test configuration without applying"
    echo "  -c, --commit         Auto-commit changes (prompts for message)"
    echo "  -m, --message MSG    Commit with specific message and apply"
    echo "  -h, --help           Show this help"
    echo ""
    echo "Examples:"
    echo "  nixos-apply-config                      # Just rebuild"
    echo "  nixos-apply-config -d                   # Test only"
    echo "  nixos-apply-config -m 'Add new package' # Commit and rebuild"
    echo "  nixos-apply-config -d -m 'Test config'  # Test, then apply if valid"
    echo ""
    echo "Workflow:"
    echo "  1. Validate environment"
    echo "  2. Test configuration (if -d)"
    echo "  3. Commit changes (if -m or -c)"
    echo "  4. Rebuild system"
    echo "  5. Push to remote (if committed)"
end
