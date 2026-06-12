function ngit
    begin
        cd $NIXOS_CONFIG_DIR
        git $argv
        cd -
    end
end
