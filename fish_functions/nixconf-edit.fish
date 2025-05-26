function nixconf-edit -d " Edit NixOS configuration.nix"
  echo " Editing NixOS configuration: $NIXOS_CONFIG_DIR/configuration.nix"
  $EDITOR $NIXOS_CONFIG_DIR/configuration.nix $argv
end
