# secrets.nix
#
# Purpose: Define public keys for agenix secret encryption
#
# This module:
# - Maps host/user identities to their public keys
# - Used by agenix to determine encryption targets
let
  popcat19 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGiKOcLWZpZToQ3rlBy439vkBMfT+E/JuK1BywvsgiqT popcat19@popcat19-nixos0";
in
{
  "zrok-share-token.age".publicKeys = [ popcat19 ];
  "sillytavern-password.age".publicKeys = [ popcat19 ];
  "klipper-wifi-psk.age".publicKeys = [ popcat19 ];
  "klipper-ap-psk.age".publicKeys = [ popcat19 ];
}
