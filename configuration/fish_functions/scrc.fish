# Purpose: Screen mirror Android device with audio via scrcpy
function scrc
    scrcpy --new-display=1920x1080 --audio-source=playback $argv
end
