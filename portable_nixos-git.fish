# Portable nixos-git function
# This is a self-contained version that doesn't depend on other fish scripts

function nixos-git
    # Check if we're in a git repository
    if not test -d ".git"
        echo "Not in a git repository. Please navigate to your NixOS configuration directory."
        return 1
    end

    # Check if there are uncommitted changes
    set git_status (git status --porcelain)
    if test -n "$git_status"
        echo "You have uncommitted changes:"
        echo "$git_status"
        echo ""
        echo "Please commit or stash your changes before proceeding."
        return 1
    end

    # Pull latest changes
    echo "Pulling latest changes from remote..."
    git pull
    if test $status -ne 0
        echo "Failed to pull latest changes. Please check the error messages above."
        return 1
    end

    echo "Successfully pulled latest changes."
end