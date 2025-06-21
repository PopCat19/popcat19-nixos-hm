# ~/nixos-config/fish_functions/nixos-apply-config.fish
function nixos-apply-config -d "🚀 Apply NixOS config with rebuild/git/rollback. Use 'nixos-apply-config help' for manual."
    # Parse arguments for -m flag and skip options
    set -l commit_message ""
    set -l skip_git false
    set -l dry_run false
    set -l rebuild_args
    set -l i 1

    while test $i -le (count $argv)
        if test "$argv[$i]" = "-m"
            if test $i -lt (count $argv)
                set i (math $i + 1)
                set commit_message "$argv[$i]"
            else
                echo "❌ Error: -m flag requires a commit message"
                return 1
            end
        else if test "$argv[$i]" = "help" -o "$argv[$i]" = "h" -o "$argv[$i]" = "--help" -o "$argv[$i]" = "-h"
            _nixos_apply_help
            return 0
        else if test "$argv[$i]" = "manual" -o "$argv[$i]" = "man" -o "$argv[$i]" = "doc"
            _nixos_apply_manual
            return 0
        else if test "$argv[$i]" = "--fast" -o "$argv[$i]" = "--skip" -o "$argv[$i]" = "-rs"
            set skip_git true
        else if test "$argv[$i]" = "--dry"
            set dry_run true
        else
            set rebuild_args $rebuild_args "$argv[$i]"
        end
        set i (math $i + 1)
    end

    if test $dry_run = true
        echo "🔍 Dry-run mode: Checking configuration without applying changes..."
        echo "    Command that would be executed:"
        echo "    sudo nixos-rebuild switch --flake \"$NIXOS_CONFIG_DIR#$NIXOS_FLAKE_HOSTNAME\" $rebuild_args"
        echo ""
        echo "🧪 Running configuration check..."
        if nix build --dry-run "$NIXOS_CONFIG_DIR#nixosConfigurations.$NIXOS_FLAKE_HOSTNAME.config.system.build.toplevel"
            echo "✅ Configuration check passed. No issues found."
            echo "💡 Use nixos-apply-config without --dry to apply changes."
            return 0
        else
            echo "❌ Configuration check failed. Fix errors before applying."
            return 1
        end
    else
        echo "🚀 Attempting to apply NixOS configuration..."
    end

    if sudo nixos-rebuild switch --flake "$NIXOS_CONFIG_DIR#$NIXOS_FLAKE_HOSTNAME" $rebuild_args
        echo "✅ NixOS rebuild and switch successful."
        echo ""

        # Handle git operations
        if test $skip_git = true
            echo "⚡ Git operations skipped (--fast/--skip flag used)."
        else if test -n "$commit_message"
            echo "💬 Committing changes with message: '$commit_message'"
            nixos-git "$commit_message"
        else
            read -P "💬 Enter commit message (or leave blank to skip git operations): " user_commit_message
            if test -n "$user_commit_message"
                nixos-git "$user_commit_message"
            else
                echo "ℹ️ Git operations skipped by user."
            end
        end
        return 0
    else
        echo "❌ NixOS rebuild and switch FAILED."
        echo ""
        read -P "󰕌 Rollback to last git commit? (y/N): " rollback_choice
        set -l lower_rollback_choice (string lower "$rollback_choice")
        if test "$lower_rollback_choice" = "y" -o "$lower_rollback_choice" = "yes"
            echo "󰕌 Attempting to rollback using git..."

            # Change to config directory for git operations
            pushd $NIXOS_CONFIG_DIR

            if not git rev-parse --is-inside-work-tree >/dev/null 2>&1
                echo "❌ Error: $NIXOS_CONFIG_DIR is not a git repository."
                echo "💡 Cannot perform git rollback. Try manual nixos-rebuild switch --rollback"
                popd
                return 1
            end

            # Check if there are uncommitted changes
            if git diff-index --quiet HEAD --
                echo "ℹ️ No uncommitted changes detected."
            else
                echo "⚠️ Uncommitted changes detected. Stashing them before rollback..."
                git stash push -m "Auto-stash before rollback from nixos-apply-config"
            end

            # Get the current commit hash for reference
            set -l current_commit (git rev-parse HEAD)
            echo "📍 Current commit: $current_commit"

            # Reset to HEAD (last commit)
            if git reset --hard HEAD
                echo "✅ Git reset successful. Configuration restored to last commit."
                popd

                # Try to rebuild with the rolled-back configuration
                echo "🔄 Rebuilding with rolled-back configuration..."
                if sudo nixos-rebuild switch --flake "$NIXOS_CONFIG_DIR#$NIXOS_FLAKE_HOSTNAME"
                    echo "✅ Rollback rebuild successful. System restored to working state."
                else
                    echo "❌ Rollback rebuild FAILED. The last commit may also have issues."
                    echo "💡 You may need to:"
                    echo "   • Check git log and reset to an earlier working commit"
                    echo "   • Use nixos-rebuild switch --rollback for generation-based rollback"
                    echo "   • Select a previous generation at boot menu"
                end
            else
                echo "❌ Git reset FAILED."
                popd
                return 1
            end
        else
            echo "ℹ️ Rollback skipped by user."
        end
        return 1
    end
end

function _nixos_apply_help -d "Show help for nixos-apply-config"
    echo "🚀 nixos-apply-config - Smart NixOS Configuration Applier"
    echo "════════════════════════════════════════════════════════════"
    echo ""
    echo "🎯 DESCRIPTION:"
    echo "   Intelligently applies NixOS configuration with automatic error handling,"
    echo "   git integration, and rollback capabilities."
    echo ""
    echo "⚙️  USAGE:"
    echo "   nixos-apply-config [options] [nixos-rebuild-options]"
    echo "   nixos-apply-config -m \"commit message\" [nixos-rebuild-options]"
    echo "   nixos-apply-config help|manual"
    echo ""
    echo "🔧 OPTIONS:"
    echo "   -m \"message\"    Commit message for successful rebuild (skips prompt)"
    echo "   --fast, --skip   Skip git operations entirely (no commit, no prompt)"
    echo "   -rs              Skip git operations (shorthand for --fast)"
    echo "   --dry            Dry-run mode (check configuration without applying)"
    echo ""
    echo "🔄 WORKFLOW:"
    echo "   1. Runs nixos-rebuild switch with your flake"
    echo "   2. On SUCCESS: Commits changes to git (with -m or prompt)"
    echo "   3. On FAILURE: Offers to rollback using git reset"
    echo ""
    echo "💡 EXAMPLES:"
    echo "   nixos-apply-config                           # Standard rebuild with prompt"
    echo "   nixos-apply-config -m \"bump flake.lock\"      # Rebuild with commit message"
    echo "   nixos-apply-config -m \"fix config\" --show-trace  # With rebuild options"
    echo "   nixos-apply-config --fast                    # Skip git operations entirely"
    echo "   nixos-apply-config -rs --show-trace          # Skip git (shorthand) + traces"
    echo "   nixos-apply-config --dry                     # Check configuration only"
    echo "   nixos-apply-config --dry --show-trace        # Dry-run with detailed traces"
    echo ""
    echo "🔗 INTEGRATIONS:"
    echo "   • Uses \$NIXOS_CONFIG_DIR and \$NIXOS_FLAKE_HOSTNAME"
    echo "   • Calls nixos-git for commit operations"
    echo "   • Git-based rollback instead of generation rollback"
    echo ""
    echo "ℹ️  For detailed information: nixos-apply-config manual"
end

function _nixos_apply_manual -d "Show detailed manual for nixos-apply-config"
    echo "📖 nixos-apply-config - Complete Manual"
    echo "════════════════════════════════════════════════════════════════════════════════"
    echo ""
    echo "🔍 OVERVIEW:"
    echo "   The core function of your NixOS management workflow. Handles the complete"
    echo "   process of applying configuration changes with intelligent git-based error handling."
    echo ""
    echo "🔄 DETAILED WORKFLOW:"
    echo ""
    echo "   1️⃣ ARGUMENT PARSING:"
    echo "      • Scans for -m flag to extract commit message"
    echo "      • Passes remaining arguments to nixos-rebuild"
    echo "      • Handles help/manual requests"
    echo ""
    echo "   2️⃣ REBUILD PHASE:"
    echo "      • Executes: sudo nixos-rebuild switch --flake \"\$NIXOS_CONFIG_DIR#\$NIXOS_FLAKE_HOSTNAME\""
    echo "      • Passes through nixos-rebuild arguments (--show-trace, --fast, etc.)"
    echo "      • Provides real-time output during build process"
    echo ""
    echo "   3️⃣ SUCCESS PHASE:"
    echo "      • Confirms successful rebuild"
    echo "      • If -m provided: Automatically commits with that message"
    echo "      • If no -m: Prompts for git commit message"
    echo "      • Calls nixos-git function for git operations"
    echo ""
    echo "   4️⃣ FAILURE PHASE:"
    echo "      • Reports build failure"
    echo "      • Offers git-based rollback to last commit"
    echo "      • If accepted: stashes changes, resets to HEAD, rebuilds"
    echo "      • Provides guidance if rollback also fails"
    echo ""
    echo "🆕 GIT-BASED ROLLBACK:"
    echo "   Unlike traditional nixos-rebuild --rollback (generation-based), this uses:"
    echo "   • git stash (preserve uncommitted changes)"
    echo "   • git reset --hard HEAD (revert to last commit)"
    echo "   • nixos-rebuild switch (rebuild with clean config)"
    echo ""
    echo "   Benefits:"
    echo "   • Consistent with version control workflow"
    echo "   • Preserves git history and commit messages"
    echo "   • Works with any commit, not just generations"
    echo "   • Integrates with collaborative development"
    echo ""
    echo "🌐 ENVIRONMENT VARIABLES:"
    echo "   • NIXOS_CONFIG_DIR: Path to your NixOS configuration directory"
    echo "   • NIXOS_FLAKE_HOSTNAME: Your system's flake hostname identifier"
    echo ""
    echo "🔧 ADVANCED OPTIONS:"
    echo "   Commit Message Flag:"
    echo "   • -m \"message\"    Specify commit message upfront"
    echo ""
    echo "   Git Skip Flags:"
    echo "   • --fast           Skip all git operations (no commit, no prompt)"
    echo "   • --skip           Skip all git operations (alias for --fast)"
    echo "   • -rs              Skip all git operations (shorthand)"
    echo ""
    echo "   Dry-run Flag:"
    echo "   • --dry            Check configuration without applying changes"
    echo ""
    echo "   nixos-rebuild Options (all supported):"
    echo "   • --show-trace          Show detailed error traces"
    echo "   • --verbose             Increase verbosity"
    echo "   • --option <name> <val> Pass option to Nix"
    echo "   • --impure              Allow impure evaluation"
    echo "   • --keep-going          Continue after build failures"
    echo ""
    echo "💡 USAGE PATTERNS:"
    echo ""
    echo "   🚀 Quick Changes:"
    echo "   nixos-apply-config -m \"quick fix\"         # No prompts, fast workflow"
    echo ""
    echo "   🔍 Debugging:"
    echo "   nixos-apply-config --show-trace           # Detailed errors, prompt for commit"
    echo ""
    echo "   ⚡ Fast Mode (Skip Git):"
    echo "   nixos-apply-config --fast                 # Just rebuild, no git operations"
    echo "   nixos-apply-config -rs --show-trace       # Skip git (shorthand) + traces"
    echo ""
    echo "   🔍 Dry-run Mode:"
    echo "   nixos-apply-config --dry                  # Check config without applying"
    echo "   nixos-apply-config --dry --show-trace     # Dry-run with detailed traces"
    echo ""
    echo "   🔍 Debug Mode:"
    echo "   nixos-apply-config -m \"test change\" --show-trace  # Show traces, auto-commit"
    echo ""
    echo "🆘 ERROR SCENARIOS & SOLUTIONS:"
    echo ""
    echo "   ❌ Build Failures:"
    echo "      • Syntax errors in configuration files"
    echo "      • Missing packages or services"
    echo "      • Hardware compatibility issues"
    echo "      → Use --show-trace for detailed error information"
    echo "      → Use git rollback to restore working configuration"
    echo ""
    echo "   ❌ Git Repository Issues:"
    echo "      • Not a git repository"
    echo "      • No commits in repository"
    echo "      → Initialize: cd \$NIXOS_CONFIG_DIR && git init"
    echo "      → First commit: git add . && git commit -m \"initial config\""
    echo ""
    echo "   ❌ Rollback Failures:"
    echo "      • Last commit also has issues"
    echo "      → Check git log for earlier working commits"
    echo "      → Manual git reset to specific commit"
    echo "      → Fall back to nixos-rebuild switch --rollback"
    echo ""
    echo "🔗 INTEGRATION WITH OTHER FUNCTIONS:"
    echo "   • nixos-edit-rebuild: Edit config → nixos-apply-config"
    echo "   • home-edit-rebuild: Edit home → nixos-apply-config"
    echo "   • nixos-upgrade: Update flake → nixos-apply-config"
    echo "   • nixpkg add --rebuild: Add package → nixos-apply-config"
    echo ""
    echo "🎮 ABBREVIATION USAGE:"
    echo "   nrb         = nixos-apply-config"
    echo "   nixos-sw    = nixos-apply-config"
    echo "   nerb        = nixos-edit-rebuild (which calls this)"
    echo "   herb        = home-edit-rebuild (which calls this)"
    echo "   nup         = nixos-upgrade (which calls this)"
    echo ""
    echo "⚡ GIT SKIP MODES:"
    echo "   --fast/--skip flags bypass all git operations for rapid iteration:"
    echo "   • No commit prompts or operations"
    echo "   • Useful for testing changes without cluttering git history"
    echo "   • Still offers rollback capability on build failures"
    echo "   • Recommended for experimental configurations"
    echo ""
    echo "🔄 MIGRATION FROM GENERATION-BASED ROLLBACK:"
    echo "   Previous behavior: nixos-rebuild switch --rollback"
    echo "   New behavior: git reset --hard HEAD + rebuild"
    echo ""
    echo "   Advantages:"
    echo "   • Works with any git commit, not just NixOS generations"
    echo "   • Maintains version control consistency"
    echo "   • Better for collaborative workflows"
    echo "   • Preserves commit history and messages"
end
