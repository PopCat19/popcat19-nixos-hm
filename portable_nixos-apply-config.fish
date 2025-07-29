# Portable nixos-apply-config function
# This is a self-contained version that doesn't depend on other fish scripts

function nixos-apply-config
    # Check if we're in a directory with a configuration.nix file
    if not test -f "configuration.nix"
        echo "No configuration.nix found in the current directory."
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
            echo "Please commit or stash your changes before applying the configuration."
            return 1
        end
    end

    # Apply the configuration
    echo "Applying NixOS configuration..."
    sudo nixos-rebuild switch

    if test $status -eq 0
        echo "Successfully applied NixOS configuration."
    else
        echo "Failed to apply NixOS configuration."
        return 1
    end
end