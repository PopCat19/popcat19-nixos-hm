# Purpose: Open a nix-shell with given packages
function nsp
    nix-shell -p $argv
end
