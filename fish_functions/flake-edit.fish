function flake-edit -d " Edit NixOS flake.nix"
  echo " Editing Flake configuration: $NIXOS_CONFIG_DIR/flake.nix"
  $EDITOR $NIXOS_CONFIG_DIR/flake.nix $argv
end
