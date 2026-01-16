#!/usr/bin/env fish

# SillyTavern Function
#
# Purpose: Launch SillyTavern with automatic updates
# Dependencies: git, SillyTavern-Launcher
# Related: fish.nix
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
