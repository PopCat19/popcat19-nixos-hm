# Purpose: Run git from the NixOS config directory
function ngit
    begin
        cd $NIXOS_CONFIG_DIR
        git $argv
        cd -
    end
end
