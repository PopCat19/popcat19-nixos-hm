# ~/nixos-config/fish_functions/nixos-git.fish
# Streamlined git operations for NixOS configuration management
# Focused, efficient git workflow integration

# Load core dependencies
set -l script_dir (dirname (status --current-filename))
source "$script_dir/nixos-core.fish"

function nixos-git -d "📝 Git operations for NixOS config (commit, push, pull, status)"
    # Parse arguments
    set -l operation ""
    set -l commit_msg ""
    set -l show_help false

    if test (count $argv) -eq 0
        set show_help true
    else
        set operation $argv[1]
        if test "$operation" = "help" -o "$operation" = "-h" -o "$operation" = "--help"
            set show_help true
        end
    end

    if test "$show_help" = true
        _nixos_git_help
        return 0
    end

    # Validate environment
    if not nixos_validate_env
        return 1
    end

    # Execute operation
    switch $operation
        case commit c
            # Commit with message from remaining args
            set commit_msg (string join " " $argv[2..-1])
            if test -z "$commit_msg"
                echo "❌ Commit requires a message"
                echo "Usage: nixos-git commit 'Your commit message'"
                return 1
            end
            _nixos_git_commit_and_push "$commit_msg"

        case push p
            _nixos_git_push_only

        case pull
            _nixos_git_pull_only $argv[2..-1]

        case status s
            _nixos_git_status_only

        case sync
            # Pull, then push any local commits
            _nixos_git_sync

        case '*'
            # Treat entire command as commit message
            set commit_msg (string join " " $argv)
            _nixos_git_commit_and_push "$commit_msg"
    end
end

function _nixos_git_commit_and_push -d "Commit changes and push"
    set -l commit_msg "$argv[1]"

    echo "📝 Committing and pushing changes..."

    if nixos_git_commit "$commit_msg"
        nixos_git_push
        return 0
    else
        return 1
    end
end

function _nixos_git_push_only -d "Push without committing"
    echo "📤 Pushing to remote..."
    nixos_git_push
end

function _nixos_git_pull_only -d "Pull from remote"
    echo "📥 Pulling from remote..."
    nixos_git_pull $argv
end

function _nixos_git_status_only -d "Show git status"
    nixos_git_status
end

function _nixos_git_sync -d "Sync with remote (pull then push)"
    echo "🔄 Syncing with remote..."

    if nixos_git_pull
        # If there were local commits, push them
        if not nixos_git_status | grep -q "No changes"
            nixos_git_push
        end
        return 0
    else
        return 1
    end
end

function _nixos_git_help
    echo "📝 nixos-git - NixOS Configuration Git Manager"
    echo ""
    echo "Usage:"
    echo "  nixos-git commit 'message'      # Commit with message and push"
    echo "  nixos-git 'commit message'      # Same as above (shortcut)"
    echo "  nixos-git push                  # Push without committing"
    echo "  nixos-git pull [options]        # Pull from remote"
    echo "  nixos-git status                # Show git status"
    echo "  nixos-git sync                  # Pull then push"
    echo "  nixos-git --help                # Show this help"
    echo ""
    echo "Examples:"
    echo "  nixos-git 'Add new packages'              # Commit and push"
    echo "  nixos-git commit 'Fix configuration'      # Explicit commit"
    echo "  nixos-git pull --rebase                   # Pull with rebase"
    echo "  nixos-git status                          # Check status"
    echo ""
    echo "Shortcuts:"
    echo "  ngit = nixos-git                # Abbreviation"
    echo ""
    echo "Workflow Integration:"
    echo "  • Used automatically by nixos-apply-config when -m flag is used"
    echo "  • Operates in \$NIXOS_CONFIG_DIR"
    echo "  • Validates git repository before operations"
    echo ""
    echo "💡 This tool focuses on the core git workflow: commit → push → pull"
end
