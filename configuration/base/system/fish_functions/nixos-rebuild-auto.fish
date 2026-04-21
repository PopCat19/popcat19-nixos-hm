# nixos-rebuild-auto.fish
#
# Purpose: Non-interactive NixOS rebuild for LLM automation
#
# This function:
# - Commits and rebuilds without interactive prompts
# - Uses flags for behavior control
# - Returns clear exit codes for automation
# - Supports automatic rollback on build failure
#
# Usage: nixos-rebuild-auto [OPTIONS] [COMMIT_MESSAGE]
#
# Options:
#   --rollback-on-fail    Rollback git commit if rebuild fails (default)
#   --no-rollback         Keep changes even if rebuild fails
#   --push-on-success     Push to remote after successful rebuild
#   --no-commit           Skip commit, just rebuild
#   --dry-run             Build without switching
#
# Exit codes:
#   0 - Success
#   1 - Build failed (and rollback failed or disabled)
#   2 - Commit failed
#   3 - Push failed
#
# Environment:
#   LLM_AUTO=1 - Force non-interactive mode (default behavior for this script)

function nixos-rebuild-auto
    set -l original_dir (pwd)
    cd $NIXOS_CONFIG_DIR

    set -l commit_message ""
    set -l rollback_on_fail true
    set -l push_on_success false
    set -l skip_commit false
    set -l action "switch"

    # Parse arguments
    set -l i 1
    while test $i -le (count $argv)
        switch $argv[$i]
            case "--rollback-on-fail"
                set rollback_on_fail true
            case "--no-rollback"
                set rollback_on_fail false
            case "--push-on-success"
                set push_on_success true
            case "--no-commit"
                set skip_commit true
            case "--dry-run"
                set action "build"
            case "--test"
                set action "test"
            case "*"
                if test -z "$commit_message"
                    set commit_message $argv[$i]
                else
                    set commit_message "$commit_message $argv[$i]"
                end
        end
        set i (math $i + 1)
    end

    # Require commit message unless --no-commit
    if test "$skip_commit" = false; and test -z "$commit_message"
        echo "[ERROR] Commit message required. Usage: nixos-rebuild-auto [OPTIONS] '<commit-message>'" >&2
        cd $original_dir
        return 1
    end

    set -l pre_commit_hash (git rev-parse HEAD)

    # Commit phase
    set -l did_commit false
    set -l commit_failed false

    if test "$skip_commit" = false
        git add .

        if git diff --cached --quiet
            echo "[INFO] Nothing to commit; proceeding with rebuild"
        else
            if git commit -m "$commit_message"
                set did_commit true
                echo "[INFO] Committed: $commit_message"
            else
                set commit_failed true
                echo "[WARN] Commit failed; proceeding with rebuild without commit" >&2
            end
        end
    end

    # Rebuild phase
    set -l rebuild_args $action --flake .

    # Kernel < 5.6 lacks sandbox support
    set -l kver (uname -r)
    if string match -qr '^([0-4]\.|5\.[0-5][^0-9])' "$kver"
        echo "[WARN] Kernel $kver (< 5.6) detected. Disabling sandbox."
        set -a rebuild_args --option sandbox false
    end

    echo "[STEP] Running nixos-rebuild $action..."

    if sudo -E nixos-rebuild $rebuild_args
        echo "[SUCCESS] Build succeeded"

        # Push phase
        if test "$push_on_success" = true; and test "$did_commit" = true
            echo "[STEP] Pushing to remote..."
            set -l branch (git branch --show-current)

            if git push 2>/dev/null
                echo "[SUCCESS] Pushed to origin/$branch"
            else
                echo "[STEP] Normal push failed, attempting rebase..."
                git fetch origin

                if git pull --rebase origin $branch 2>/dev/null
                    if git push 2>/dev/null
                        echo "[SUCCESS] Rebased and pushed to origin/$branch"
                    else
                        echo "[ERROR] Push failed after rebase" >&2
                        cd $original_dir
                        return 3
                    end
                else
                    echo "[ERROR] Rebase failed, manual intervention required" >&2
                    cd $original_dir
                    return 3
                end
            end
        end

        cd $original_dir
        return 0
    else
        echo "[ERROR] Build failed" >&2

        # Rollback phase
        if test "$rollback_on_fail" = true; and test "$did_commit" = true
            echo "[STEP] Rolling back to: $pre_commit_hash"
            git reset --hard $pre_commit_hash
            echo "[INFO] Git state restored to pre-commit"
        end

        cd $original_dir
        return 1
    end
end