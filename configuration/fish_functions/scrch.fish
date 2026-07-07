# Purpose: Screen mirror Android with high bitrate audio
function scrch
    scrcpy --new-display=1920x1080 --audio-source=playback --video-bit-rate=20M $argv
end
