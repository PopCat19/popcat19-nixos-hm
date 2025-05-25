function nixos-git -d "Commit and push NixOS configuration changes"
  if test (count $argv) -eq 0
    echo "Usage: nixos-git \"Your full commit message\""
    echo "Or:    nixos-git pull [git pull arguments]"
    return 1
  end

  echo "==> Changing to $NIXOS_CONFIG_DIR to perform git operations..."
  pushd $NIXOS_CONFIG_DIR

  # No sudo needed for git operations in user-owned directory
  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1
    echo "Error: $NIXOS_CONFIG_DIR does not appear to be a git repository."
    popd
    return 1
  end

  if test "$argv[1]" = "pull"
    set -l pull_args $argv[2..-1]
    echo "--> Pulling latest changes from remote..."
    if git pull $pull_args
      echo "--> Git pull successful."
    else
      echo "--> Git pull failed."
      popd
      return 1
    end
  else
    set -l full_commit_message (string join " " $argv)
    echo "--> Adding all changes to staging (git add .)..."
    git add .
    set -l git_status_output (git status --porcelain)

    if test -z "$git_status_output"
      echo "--> No changes to commit. Working tree is clean."
      popd
      return 0
    end

    echo "--> Committing changes with message: '$full_commit_message' (git commit)..."
    if git commit -m "$full_commit_message"
      echo "--> Pushing changes to remote (git push)..."
      if git push
         echo "==> NixOS configuration changes pushed successfully."
      else
         echo "==> Git push failed."
         popd
         return 1
      end
    else
      echo "==> Git commit failed."
      popd
      return 1
    end
  end
  popd
end
