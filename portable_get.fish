# Portable get function
# This is a self-contained version that doesn't depend on other fish scripts

function get
    # Check if an argument was provided
    if test (count $argv) -eq 0
        echo "Usage: get <package-name>"
        echo "Installs a package using the system package manager."
        return 1
    end

    set package $argv[1]

    # Detect the package manager and install the package
    if command -v apt-get >/dev/null 2>&1
        echo "Installing $package using apt-get..."
        sudo apt-get update
        sudo apt-get install -y $package
    else if command -v dnf >/dev/null 2>&1
        echo "Installing $package using dnf..."
        sudo dnf install -y $package
    else if command -v pacman >/dev/null 2>&1
        echo "Installing $package using pacman..."
        sudo pacman -S --noconfirm $package
    else if command -v zypper >/dev/null 2>&1
        echo "Installing $package using zypper..."
        sudo zypper install -y $package
    else if command -v eopkg >/dev/null 2>&1
        echo "Installing $package using eopkg..."
        sudo eopkg it -y $package
    else if command -v xbps-install >/dev/null 2>&1
        echo "Installing $package using xbps-install..."
        sudo xbps-install -S -y $package
    else if command -v nix-env >/dev/null 2>&1
        echo "Installing $package using nix-env..."
        nix-env -iA nixpkgs.$package
    else
        echo "No supported package manager found."
        echo "Supported package managers: apt-get, dnf, pacman, zypper, eopkg, xbps-install, nix-env"
        return 1
    end

    if test $status -eq 0
        echo "Successfully installed $package."
    else
        echo "Failed to install $package."
        return 1
    end
end