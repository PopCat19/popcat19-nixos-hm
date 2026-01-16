#!/usr/bin/env fish

# NixOS Commit Rebuild Push Function
#
# Purpose: Commit, rebuild, and push NixOS configuration changes
# Dependencies: git, sudo, nixos-rebuild, git-push
# Related: nixos-rebuild-basic.fish, dev-to-main.fish
#
# This function:
# - Commits configuration changes with provided message
# - Performs nixos-rebuild switch with flake
# - Handles push conflicts with rebase and force push options
# - Provides rollback capability on build failures

function nixos-commit-rebuild-push
    set -l original_dir (pwd)
    cd $NIXOS_CONFIG_DIR

    set -l commit_message ""
    set -l deprecated_flag_used false

    set -l i 1
    while test $i -le (count $argv)
        switch $argv[$i]
            case "--build-host" "--remote"
                set deprecated_flag_used true
                if test $argv[$i] = "--build-host"
                    set i (math $i + 1)
                end
            case "*"
                if test -z "$commit_message"
                    set commit_message $argv[$i]
                else
                    set commit_message "$commit_message $argv[$i]"
                end
        end
        set i (math $i + 1)
    end

    if test "$deprecated_flag_used" = "true"
        set_color yellow; echo "[WARN] Remote builds are deprecated and have been removed. Ignoring remote flags and proceeding with local build."; set_color normal
    end

    if test -z "$commit_message"
        set_color red; echo "[ERROR] Usage: nixos-commit-rebuild-push '<commit-message>'"; set_color normal
        set_color cyan; echo "[INFO] Example: nixos-commit-rebuild-push 'update config'"; set_color normal
        cd $original_dir
        return 1
    end

    set -l pre_commit_hash (git rev-parse HEAD)

    git add .

    set -l did_commit false
    set -l commit_failed false
    set -l nothing_to_commit false

    if git diff --cached --quiet
        set nothing_to_commit true
        set_color green; echo "[INFO] Nothing to commit; proceeding with rebuild"; set_color normal
    else
        if git commit -m "$commit_message"
            set did_commit true
        else
            set commit_failed true
            set_color yellow; echo "[WARN] Commit failed; proceeding with rebuild without pushing"; set_color normal
        end
    end

    if sudo nixos-rebuild switch --flake .
        if test "$did_commit" = true; or test "$nothing_to_commit" = true
            if test "$nothing_to_commit" = true
                set -l success_msg "[SUCCESS] Build succeeded, configuration up to date and remote synced"
                set -l force_msg "[SUCCESS] Build succeeded, configuration force-synced to remote"
                set -l skip_msg "[WARN] Build succeeded but configuration not pushed to remote"
            else
                set -l success_msg "[SUCCESS] Build succeeded, changes pushed to remote"
                set -l force_msg "[SUCCESS] Build succeeded, changes force-pushed to remote"
                set -l skip_msg "[WARN] Build succeeded but changes not pushed to remote"
            end

            set -l branch (git branch --show-current)
            if git push 2>/dev/null
                echo "$success_msg"
            else
                echo ""
                set_color yellow; echo "[WARN] Normal push failed - likely due to diverged history"; set_color normal
                set_color cyan; echo "[INFO] This can happen after rollbacks or when remote is ahead"; set_color normal
                echo ""

                set_color blue; echo "[STEP] Fetching latest remote changes..."; set_color normal
                git fetch origin

                read -l -P "Try rebase to integrate remote changes? [y/N]: " rebase_choice

                set -l pushed false
                if test "$rebase_choice" = "y"; or test "$rebase_choice" = "Y"
                    set_color blue; echo "[STEP] Rebasing local commits onto remote $branch..."; set_color normal
                    if git pull --rebase origin $branch
                        set_color green; echo "[SUCCESS] Rebase successful, trying push again..."; set_color normal
                        if git push 2>/dev/null
                            echo "$success_msg"
                            set pushed true
                        else
                            set pushed false
                        end
                    else
                        set_color red; echo "[ERROR] Rebase failed (likely merge conflicts)"; set_color normal
                        set pushed false
                    end
                end

                if test "$pushed" != true
                    echo ""
                    set_color red; echo "[ERROR] Push failed. Force push required to update remote branch"; set_color normal
                    for i in (seq 5 -1 1)
                        printf "\r[STEP] Force push in %d seconds... (Ctrl+C to cancel)" $i
                        sleep 1
                    end
                    echo ""

                    read -l -P "Proceed with force push? [y/N]: " force_push_choice

                    if test "$force_push_choice" = "y"; or test "$force_push_choice" = "Y"
                        git push --force-with-lease
                        echo "$force_msg"
                    else
                        echo "$skip_msg"
                        set_color cyan; echo "[INFO] You can manually push later with: git push --force-with-lease"; set_color normal
                    end
                end
            end
        else
            set_color yellow; echo "[WARN] Build succeeded but skipping push due to commit failure"; set_color normal
        end
    else
        set_color red; echo "[ERROR] Build failed, changes not pushed"; set_color normal
        echo ""
        read -l -P "Do you want to rollback to the previous commit? [y/N]: " rollback_choice

        if test "$rollback_choice" = "y"; or test "$rollback_choice" = "Y"
            git reset --hard $pre_commit_hash
            set_color blue; echo "[STEP] Rolled back to commit: $pre_commit_hash"; set_color normal
            set_color cyan; echo "[INFO] Your changes have been reverted"; set_color normal
            echo ""
            set_color yellow; echo "[WARN] Note: If you had pushed this commit before, you may need to force push"; set_color normal
            echo "   after your next successful commit to sync the remote branch"
        else
            set_color yellow; echo "[WARN] Changes kept in current commit. You can manually rollback with:"; set_color normal
            echo "   git reset --hard $pre_commit_hash"
            echo ""
            set_color cyan; echo "[INFO] If you rollback later and then push, you may need --force-with-lease"; set_color normal
        end
    end
    cd $original_dir
end
