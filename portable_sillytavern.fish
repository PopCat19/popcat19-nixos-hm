# Portable sillytavern function
# This is a self-contained version that doesn't depend on other fish scripts

function sillytavern
    # Check if SillyTavern directory exists
    if not test -d "$HOME/SillyTavern"
        echo "SillyTavern directory not found in $HOME/SillyTavern"
        echo "Please install SillyTavern first."
        return 1
    end

    # Change to SillyTavern directory
    cd "$HOME/SillyTavern"

    # Check if package.json exists
    if not test -f "package.json"
        echo "package.json not found. This doesn't appear to be a valid SillyTavern installation."
        return 1
    end

    # Check if node_modules exists
    if not test -d "node_modules"
        echo "node_modules not found. Running npm install..."
        npm install
        if test $status -ne 0
            echo "Failed to install dependencies. Please check the error messages above."
            return 1
        end
    end

    # Start SillyTavern
    echo "Starting SillyTavern..."
    npm start
end