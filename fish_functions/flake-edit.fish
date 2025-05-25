function flake-edit -d "Edit NixOS flake.nix"
  $EDITOR $NIXOS_CONFIG_DIR/flake.nix $argv
end
