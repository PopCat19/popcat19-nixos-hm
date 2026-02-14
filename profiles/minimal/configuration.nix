# configuration.nix
#
# Purpose: Minimal configuration preset for limited hardware or testing
#
# This module:
# - Imports only essential system modules
# - Skips extended/desktop modules
# - Suitable for servers, VMs, or resource-constrained devices
{ ... }:
{
  imports = [
    ../../configuration/system/modules/boot.nix
    ../../configuration/system/modules/core-packages.nix
    ../../configuration/system/modules/environment.nix
    ../../configuration/system/modules/hardware.nix
    ../../configuration/system/modules/localization.nix
    ../../configuration/system/modules/networking.nix
    ../../configuration/system/modules/packages.nix
    ../../configuration/system/modules/services.nix
    ../../configuration/system/modules/ssh.nix
    ../../configuration/system/modules/users.nix
  ];

  nix = {
    gc = {
      automatic = true;
      dates = "03:00";
      options = "--delete-older-than 7d";
    };

    settings = {
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
  };

  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "25.05";
}
