#!/usr/bin/env fish

# Dev to Main Function
#
# Purpose: Merge dev branch changes into main branch
# Dependencies: git, git-merge, git-push, git-checkout
# Related: nixos-commit-rebuild-push.fish, fish.nix
#
# This function:
# - Validates current branch is 'dev'
# - Checks for uncommitted changes
# - Fetches latest remote changes
# - Performs conflict detection and resolution
# - Merges dev into main and pushes to remote

function dev-to-main
    set -l original_dir (pwd)
    cd $NIXOS_CONFIG_DIR

    # Check if we're on dev branch
    set -l current_branch (git branch --show-current)
    if test "$current_branch" != "dev"
        set_color red; echo "[ERROR] Not on dev branch. Currently on: $current_branch"; set_color normal
        set_color cyan; echo "[INFO] Switch to dev branch first: git checkout dev"; set_color normal
        cd $original_dir
        return 1
    end

    # Check for uncommitted changes
    if not git diff --quiet; or not git diff --cached --quiet
        set_color red; echo "[ERROR] You have uncommitted changes on dev branch"; set_color normal
        set_color cyan; echo "[INFO] Commit or stash your changes first"; set_color normal
        git status --short
        cd $original_dir
        return 1
    end

    # Fetch latest changes
    set_color blue; echo "[STEP] Fetching latest changes..."; set_color normal
    git fetch origin

    # Check if dev is behind origin/dev
    set -l dev_behind (begin; git rev-list --count HEAD..origin/dev 2>/dev/null; or echo 0; end)
    if test "$dev_behind" -gt 0
        set_color red; echo "[ERROR] Your dev branch is $dev_behind commits behind origin/dev"; set_color normal
        set_color cyan; echo "[INFO] Pull latest changes first: git pull origin dev"; set_color normal
        cd $original_dir
        return 1
    end

    # Check if dev is ahead of origin/dev (unpushed commits)
    set -l dev_ahead (begin; git rev-list --count origin/dev..HEAD 2>/dev/null; or echo 0; end)
    if test "$dev_ahead" -gt 0
        set_color red; echo "[ERROR] You have $dev_ahead unpushed commits on dev"; set_color normal
        set_color cyan; echo "[INFO] Push your dev changes first: git push origin dev"; set_color normal
        cd $original_dir
        return 1
    end

    # Switch to main and check for conflicts
    set_color blue; echo "[STEP] Switching to main branch..."; set_color normal
    git checkout main

    # Check if main is behind origin/main
    set -l main_behind (begin; git rev-list --count HEAD..origin/main 2>/dev/null; or echo 0; end)
    if test "$main_behind" -gt 0
        set_color blue; echo "[STEP] Pulling latest main changes..."; set_color normal
        git pull origin main
    end

    # Check for potential merge conflicts
    set_color blue; echo "[STEP] Checking for potential merge conflicts..."; set_color normal
    if not git merge --no-commit --no-ff dev >/dev/null 2>&1
        git merge --abort 2>/dev/null
        set_color red; echo "[ERROR] Merge conflicts detected between dev and main"; set_color normal
        set_color cyan; echo "[INFO] Resolve conflicts manually or use a different merge strategy"; set_color normal
        git checkout dev
        cd $original_dir
        return 1
    end

    # Abort the test merge
    git merge --abort 2>/dev/null

    # Perform the actual merge
    set_color green; echo "[SUCCESS] No conflicts detected. Merging dev into main..."; set_color normal
    git merge dev --no-ff -m "Merge dev into main"

    # Push to main
    set_color blue; echo "[STEP] Pushing to main..."; set_color normal
    git push origin main

    # Switch back to dev
    set_color blue; echo "[STEP] Switching back to dev branch..."; set_color normal
    git checkout dev

    set_color green; echo "[SUCCESS] Successfully merged dev into main and pushed to remote"; set_color normal
    cd $original_dir
end
