# ~/nixos-config/fish_functions/nixos-git.fish
function nixos-git -d "󰊢 Git operations for NixOS config with add/commit/push/pull. Use 'nixos-git help' for manual."
    if test (count $argv) -eq 0
        _nixos_git_help
        return 1
    end
    
    # Show help if requested
    if test "$argv[1]" = "help" -o "$argv[1]" = "h" -o "$argv[1]" = "--help" -o "$argv[1]" = "-h"
        _nixos_git_help
        return 0
    else if test "$argv[1]" = "manual" -o "$argv[1]" = "man" -o "$argv[1]" = "doc"
        _nixos_git_manual
        return 0
    end

    echo "==> 󰊢 Changing to $NIXOS_CONFIG_DIR for git operations..."
    pushd $NIXOS_CONFIG_DIR

    if not git rev-parse --is-inside-work-tree >/dev/null 2>&1
        echo "❌ Error: $NIXOS_CONFIG_DIR does not appear to be a git repository."
        echo "💡 Initialize with: git init && git remote add origin <your-repo>"
        popd
        return 1
    end

    if test "$argv[1]" = "pull"
        set -l pull_args $argv[2..-1]
        echo "--> 󰊢 Pulling latest changes from remote..."
        if git pull $pull_args
            echo "--> ✅ Git pull successful."
        else
            echo "--> ❌ Git pull failed."
            popd
            return 1
        end
    else if test "$argv[1]" = "push"
        set -l push_args $argv[2..-1]
        echo "--> 󰊢 Pushing to remote (git push $push_args)..."
        if git push $push_args
           echo "==> ✅ Git push successful."
        else
           echo "==> ❌ Git push failed."
           popd
           return 1
        end
    else
        set -l full_commit_message (string join " " $argv)
        set -l changes_to_commit false

        echo "--> 󰊢 Adding all changes to staging (git add .)..."
        git add .

        # Check if there's anything to commit
        set -l git_status_output (git status --porcelain | string trim)
        if test -n "$git_status_output"
            set changes_to_commit true
        end

        if $changes_to_commit
            echo "--> 💬 Committing changes with message: '$full_commit_message' (git commit)..."
            if git commit -m "$full_commit_message"
                echo "--> ✅ Commit successful."
            else
                echo "==> ⚠️ Git commit failed or nothing to commit after add."
            end
        else
            echo "--> ℹ️ No local changes to commit."
        end

        echo "--> 󰊢 Pushing to remote (git push)..."
        if git push
           echo "==> ✅ Git push successful."
        else
           echo "==> ❌ Git push failed."
           popd
           return 1
        end
    end
    popd
end

function _nixos_git_help -d "Show help for nixos-git"
    echo "󰊢 nixos-git - NixOS Configuration Git Manager"
    echo "════════════════════════════════════════════════════════════"
    echo ""
    echo "🎯 DESCRIPTION:"
    echo "   Streamlined git operations for your NixOS configuration repository."
    echo "   Handles the complete workflow: add → commit → push."
    echo ""
    echo "⚙️  USAGE:"
    echo "   nixos-git \"commit message\"           # Add, commit, and push"
    echo "   nixos-git pull [options]              # Pull from remote"
    echo "   nixos-git push [options]              # Push to remote"
    echo "   nixos-git help|manual                 # Show documentation"
    echo ""
    echo "💡 EXAMPLES:"
    echo "   nixos-git \"🎮 Add gaming packages\"    # Standard workflow"
    echo "   nixos-git pull --rebase               # Pull with rebase"
    echo "   nixos-git push --force-with-lease     # Safe force push"
    echo ""
    echo "🔗 INTEGRATIONS:"
    echo "   • Automatically called by nixos-apply-config after successful rebuilds"
    echo "   • Uses \$NIXOS_CONFIG_DIR environment variable"
    echo "   • Compatible with your ngit abbreviation"
    echo ""
    echo "ℹ️  For detailed information: nixos-git manual"
end

function _nixos_git_manual -d "Show detailed manual for nixos-git"
    echo "📖 nixos-git - Complete Manual"
    echo "════════════════════════════════════════════════════════════════════════════════"
    echo ""
    echo "🔍 OVERVIEW:"
    echo "   Specialized git wrapper for NixOS configuration management. Provides a"
    echo "   streamlined interface for version controlling your system configuration."
    echo ""
    echo "🔄 OPERATION MODES:"
    echo ""
    echo "   1️⃣ COMMIT MODE (default):"
    echo "      Command: nixos-git \"Your commit message\""
    echo "      Process:"
    echo "        • Changes to \$NIXOS_CONFIG_DIR"
    echo "        • Stages all changes (git add .)"
    echo "        • Commits with provided message"
    echo "        • Pushes to remote repository"
    echo ""
    echo "   2️⃣ PULL MODE:"
    echo "      Command: nixos-git pull [git-pull-options]"
    echo "      Purpose: Sync with remote repository"
    echo "      Examples:"
    echo "        nixos-git pull                    # Standard pull"
    echo "        nixos-git pull --rebase          # Pull with rebase"
    echo "        nixos-git pull origin main       # Pull specific branch"
    echo ""
    echo "   3️⃣ PUSH MODE:"
    echo "      Command: nixos-git push [git-push-options]"
    echo "      Purpose: Push without commit"
    echo "      Examples:"
    echo "        nixos-git push                    # Standard push"
    echo "        nixos-git push --force-with-lease # Safe force push"
    echo "        nixos-git push origin feature     # Push to branch"
    echo ""
    echo "🛡️  SAFETY FEATURES:"
    echo "   • Repository validation before operations"
    echo "   • Change detection before committing"
    echo "   • Clear success/failure reporting"
    echo "   • Automatic directory context switching"
    echo ""
    echo "📂 ENVIRONMENT SETUP:"
    echo "   Required Variables:"
    echo "   • NIXOS_CONFIG_DIR: Path to your NixOS configuration directory"
    echo ""
    echo "   Repository Requirements:"
    echo "   • Must be a valid git repository"
    echo "   • Should have a configured remote origin"
    echo "   • Proper authentication for push operations"
    echo ""
    echo "🔗 WORKFLOW INTEGRATION:"
    echo ""
    echo "   📝 Typical Development Cycle:"
    echo "     1. Edit configuration files"
    echo "     2. Test with nixos-apply-config"
    echo "     3. On success, nixos-apply-config prompts for commit"
    echo "     4. nixos-git handles the git workflow"
    echo ""
    echo "   🔄 Collaboration Workflow:"
    echo "     1. nixos-git pull                 # Get latest changes"
    echo "     2. Make local modifications"
    echo "     3. nixos-apply-config            # Test changes"
    echo "     4. nixos-git \"Description\"       # Commit and push"
    echo ""
    echo "💡 COMMIT MESSAGE BEST PRACTICES:"
    echo "   • Use descriptive messages: \"🎮 Add gaming packages and configs\""
    echo "   • Include emojis for visual categorization"
    echo "   • Reference issues: \"🐛 Fix hyprland config (fixes #123)\""
    echo "   • Group related changes: \"⚙️ Update all development tools\""
    echo ""
    echo "🆘 TROUBLESHOOTING:"
    echo ""
    echo "   ❌ \"Not a git repository\":"
    echo "      → Initialize: cd \$NIXOS_CONFIG_DIR && git init"
    echo "      → Add remote: git remote add origin <repo-url>"
    echo ""
    echo "   ❌ Push failures:"
    echo "      → Check authentication: git remote -v"
    echo "      → Pull first: nixos-git pull"
    echo "      → Force push carefully: nixos-git push --force-with-lease"
    echo ""
    echo "   ❌ Merge conflicts:"
    echo "      → Manual resolution required"
    echo "      → Use git status and resolve conflicts"
    echo "      → Continue with normal nixos-git workflow"
    echo ""
    echo "🎮 ABBREVIATION USAGE:"
    echo "   ngit = nixos-git    # Your existing abbreviation"
end
