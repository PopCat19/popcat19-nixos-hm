# Consolidated portable fish functions
# This file contains self-contained versions of:
# - sillytavern
# - nixos-git
# - get
# - flake-update
# - nixos-apply-config

# Each function is designed to work independently without relying on other fish scripts

# Portable sillytavern function
function sillytavern
    # Check if SillyTavern directory exists
    if test -d "$HOME/SillyTavern"
        # Change to SillyTavern directory
        cd "$HOME/SillyTavern"
        
        # Check if package.json exists
        if test -f "package.json"
            # Check if node_modules exists
            if not test -d "node_modules"
                echo "Installing dependencies..."
                npm install
            end
            
            # Start SillyTavern
            echo "Starting SillyTavern..."
            npm start
        else
            echo "package.json not found in SillyTavern directory."
            echo "Please ensure SillyTavern is properly installed."
            return 1
        end
    else
        echo "SillyTavern directory not found in $HOME."
        echo "Please install SillyTavern first."
        return 1
    end
end

# Portable nixos-git function
function nixos-git
    # Check if we're in a directory with a configuration.nix file
    if not test -f "configuration.nix"
        echo "No configuration.nix found in the current directory."
        echo "Please navigate to your NixOS configuration directory."
        return 1
    end

    # Check if we're in a git repository
    if not test -d ".git"
        echo "Not a git repository."
        echo "Initializing git repository..."
        git init
        echo "Creating initial commit..."
        git add .
        git commit -m "Initial commit"
    end

    # Check if there are uncommitted changes
    set git_status (git status --porcelain)
    if test -n "$git_status"
        echo "You have uncommitted changes:"
        echo "$git_status"
        echo ""
        echo "Please commit your changes:"
        echo "  git add ."
        echo "  git commit -m \"Your commit message\""
        return 1
    end

    # Pull latest changes
    echo "Pulling latest changes..."
    git pull

    if test $status -eq 0
        echo "Successfully pulled latest changes."
    else
        echo "Failed to pull latest changes."
        return 1
    end
end

# Portable get function
function get
    # Check if an argument was provided
    if test (count $argv) -eq 0
        echo "Usage: get <package>"
        echo "Install a package using the system package manager."
        return 1
    end

    set package $argv[1]

    # Determine the package manager and install the package
    if command -v apt-get > /dev/null
        echo "Installing $package using apt-get..."
        sudo apt-get install -y $package
    else if command -v dnf > /dev/null
        echo "Installing $package using dnf..."
        sudo dnf install -y $package
    else if command -v pacman > /dev/null
        echo "Installing $package using pacman..."
        sudo pacman -S --noconfirm $package
    else if command -v zypper > /dev/null
        echo "Installing $package using zypper..."
        sudo zypper install -y $package
    else if command -v nix-env > /dev/null
        echo "Installing $package using nix-env..."
        nix-env -iA nixos.$package
    else
        echo "No supported package manager found."
        echo "Supported package managers: apt-get, dnf, pacman, zypper, nix-env"
        return 1
    end

    if test $status -eq 0
        echo "Successfully installed $package."
    else
        echo "Failed to install $package."
        return 1
    end
end

# Portable flake-update function
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

# Portable nixos-apply-config function
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