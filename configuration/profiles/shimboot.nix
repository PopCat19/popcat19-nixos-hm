# shimboot.nix
#
# Purpose: Shimboot profile preset for ChromeOS devices with dedede board
#
# This profile:
# - Imports shimboot chromeos base configuration
# - Includes desktop environment (inclusive for usability on low hardware)
# - Configures for x86_64 ChromeOS devices
{
  userConfig,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  stateVersion = import ../stateversion.nix;
in
{
  imports = [
    # Import shimboot chromeos module and pass userConfig via _module.args
    inputs.shimboot.nixosModules.chromeos

    # Override shimboot config conflicts
    (lib.mkOverride 99 {
      nix.settings.max-jobs = lib.mkDefault "auto";
    })
  ];

  # Enable firewall (nixos-config default)
  networking.firewall.enable = lib.mkForce true;

  # Use nixos-config's state version
  system.stateVersion = lib.mkForce stateVersion.system;

  # Re-export userConfig for shimboot modules
  _module.args.userConfig = userConfig;

  home-manager.users.${userConfig.username} = {
    imports = [ ../home/modules ];
  };
}
