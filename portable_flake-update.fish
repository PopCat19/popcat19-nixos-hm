# Portable flake-update function
# This is a self-contained version that doesn't depend on other fish scripts

function flake-update
    # Check if we're in a directory with a flake.nix file
    if not test -f "flake.nix"
        echo "No flake.nix found in the current directory."
        echo "Please navigate to your NixOS configuration directory."
        return 1
    end

    # Check if we're in a git repository
    if test -d ".git"
        # Check if there are uncommitted changes
        set git_status (git status --porcelain)
        if test -n "$git_status"
            echo "You have uncommitted changes:"
            echo "$git_status"
            echo ""
            echo "Please commit or stash your changes before updating the flake."
            return 1
        end
    end

    # Update the flake
    echo "Updating flake inputs..."
    nix flake update

    if test $status -eq 0
        echo "Successfully updated flake inputs."
        echo ""
        echo "You may want to rebuild your system with the updated inputs:"
        echo "  sudo nixos-rebuild switch"
    else
        echo "Failed to update flake inputs."
        return 1
    end
end