# This function now uses $NIXOS_CONFIG_DIR set by Home Manager's shellInit
# and does NOT use sudo for editing.
function nixconf-edit -d "Edit NixOS configuration.nix"
  $EDITOR $NIXOS_CONFIG_DIR/configuration.nix $argv
end
