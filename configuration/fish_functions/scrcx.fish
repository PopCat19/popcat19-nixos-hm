# Purpose: Screen mirror Android device without audio
function scrcx
    scrcpy --new-display=1920x1080 --no-audio $argv
end
