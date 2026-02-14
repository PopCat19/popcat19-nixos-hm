# sillytavern.fish
#
# Purpose: Launch SillyTavern with automatic updates
#
# This function:
# - Navigates to SillyTavern directory
# - Pulls latest staging updates
# - Starts the SillyTavern server
# - Returns to original directory

function sillytavern
    begin
        cd ~/SillyTavern-Launcher/SillyTavern
        git pull origin staging 2>/dev/null; or true
        ./start.sh
        cd -
    end
end
