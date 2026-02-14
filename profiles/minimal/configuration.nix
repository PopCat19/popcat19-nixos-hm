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
    ../../configuration/system/system_modules/boot.nix
    ../../configuration/system/system_modules/core-packages.nix
    ../../configuration/system/system_modules/environment.nix
    ../../configuration/system/system_modules/hardware.nix
    ../../configuration/system/system_modules/localization.nix
    ../../configuration/system/system_modules/networking.nix
    ../../configuration/system/system_modules/packages.nix
    ../../configuration/system/system_modules/services.nix
    ../../configuration/system/system_modules/ssh.nix
    ../../configuration/system/system_modules/users.nix
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
