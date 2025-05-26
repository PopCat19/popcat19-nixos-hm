# ~/nixos-config/fish_functions/nixos-git.fish
function nixos-git -d "Commit and/or push NixOS configuration changes"
  if test (count $argv) -eq 0
    echo "Usage: nixos-git \"Your full commit message\" [then pushes]"
    echo "Or:    nixos-git pull [git pull arguments]"
    echo "Or:    nixos-git push [git push arguments] (to just push)"
    return 1
  end

  echo "==> Changing to $NIXOS_CONFIG_DIR to perform git operations..."
  pushd $NIXOS_CONFIG_DIR

  if not git rev-parse --is-inside-work-tree >/dev/null 2>&1
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
  else if test "$argv[1]" = "push"
    set -l push_args $argv[2..-1]
    echo "--> Pushing to remote (git push $push_args)..."
    if git push $push_args
       echo "==> Git push successful."
    else
       echo "==> Git push failed."
       popd
       return 1
    end
  else
    # Assume it's a commit message
    set -l full_commit_message (string join " " $argv)
    set -l changes_staged false

    echo "--> Adding all changes to staging (git add .)..."
    git add .

    if not test -z (git status --porcelain)
        set changes_staged true
    end

    if $changes_staged
        echo "--> Committing changes with message: '$full_commit_message' (git commit)..."
        if git commit -m "$full_commit_message"
            echo "--> Commit successful."
        else
            echo "==> Git commit failed. (Maybe an empty commit?)"
            # Don't necessarily fail the whole operation if commit fails due to no changes after add
            # but message was provided. We'll still try to push.
        end
    else
        echo "--> No local changes to commit."
    end

    # Always attempt to push after a commit attempt or if just a message was given
    echo "--> Pushing to remote (git push)..."
    if git push
       echo "==> Git push successful."
    else
       echo "==> Git push failed."
       popd
       return 1
    end
  end
  popd
end
