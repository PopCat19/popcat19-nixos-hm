# kanata.nix
#
# Purpose: Provide uinput device access for the kanata home-manager module
#
# This module:
# - Enables hardware.uinput so /dev/uinput is available
# - Adds the user to the uinput supplementary group so the user systemd
#   service can open the device without root
# - Is a no-op when disabled; only hosts that opt in get the changes
{
  config,
  lib,
  userConfig,
  ...
}:
let
  cfg = config.services.kanataUdev;
in
{
  options.services.kanataUdev = {
    enable = lib.mkEnableOption "uinput device access for the kanata home-manager module";
  };

  config = lib.mkIf cfg.enable {
    hardware.uinput.enable = true;
    users.users.${userConfig.username}.extraGroups = lib.mkAfter [ "uinput" ];
  };
}
