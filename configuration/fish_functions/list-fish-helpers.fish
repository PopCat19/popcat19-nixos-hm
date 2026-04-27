# list-fish-helpers.fish
#
# Purpose: Display all available Fish functions and abbreviations
#
# This function:
# - Lists all custom Fish functions
# - Shows all Fish abbreviations
# - Provides usage tips for discovery
# - Formats output for readability

function list-fish-helpers
    set_color blue; echo "[FISH] Fish Helpers & Shortcuts"; set_color normal
    echo "¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯"

    set_color green; echo "[INFO] Custom Functions:"; set_color normal
    set -l func_dir $NIXOS_CONFIG_DIR/configuration/fish_functions
    if test -d $func_dir
        for f in $func_dir/*.fish
            set -l func_name (path basename --no-extension $f)
            functions -q $func_name; and echo "   - $func_name"
        end | sort
    else
        echo "   (fish_functions directory not found)"
    end

    echo ""
    set_color green; echo "[INFO] All Abbreviations:"; set_color normal
    abbr --list | sort | awk '{print "   - " $0}'

    echo "¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯"
    set_color cyan; echo "[INFO] Tips:"; set_color normal
    echo "   Type 'type <name>' to see definition"
    echo "   Type 'fixhist' to repair corrupt history"
    echo "   Run this function: list-fish-helpers"
end
