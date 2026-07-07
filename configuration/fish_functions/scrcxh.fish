# Purpose: Screen mirror Android without audio, high bitrate
function scrcxh
    scrcpy --new-display=1920x1080 --no-audio --video-bit-rate=20M $argv
end
