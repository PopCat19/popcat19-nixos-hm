# Purpose: Hard reset git working tree
function greset
    git reset --hard && git clean -fd
end
