function homeconf-edit -d " Edit Home Manager home.nix"
  echo " Editing Home Manager configuration: $NIXOS_CONFIG_DIR/home.nix"
  $EDITOR $NIXOS_CONFIG_DIR/home.nix $argv
end
