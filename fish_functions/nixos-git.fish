# ~/nixos-config/fish_functions/nixos-git.fish
function nixos-git -d "󰊢 Git operations for NixOS configuration"
  if test (count $argv) -eq 0
    echo "Usage: nixos-git \"💬 Your full commit message\" [then pushes]"
    echo "Or:    nixos-git pull [git pull arguments]"
    echo "Or:    nixos-git push [git push arguments] (to just push)"
    return 1
  end

  echo "==> 󰊢 Changing to $NIXOS_CONFIG_DIR for git operations..."
  pushd $NIXOS_CONFIG_DIR

  if not git rev-parse --is-inside-work-tree >/dev/null 2>&1
    echo "❌ Error: $NIXOS_CONFIG_DIR does not appear to be a git repository."
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
    set -l changes_to_commit false # Renamed for clarity

    echo "--> 󰊢 Adding all changes to staging (git add .)..."
    git add .

    # Check if there's anything to commit
    set -l git_status_output (git status --porcelain | string trim)
    if test -n "$git_status_output" # If output is NOT empty, there are changes
        set changes_to_commit true
    end

    if $changes_to_commit
        echo "--> 💬 Committing changes with message: '$full_commit_message' (git commit)..."
        if git commit -m "$full_commit_message"
            echo "--> ✅ Commit successful."
        else
            # This might happen if 'git add .' didn't actually stage anything new
            # despite porcelain output, or if commit hook fails, etc.
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
