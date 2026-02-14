# minimal.nix
#
# Purpose: Minimal configuration preset for limited hardware or testing
#
# This profile:
# - Imports only essential system modules
# - Skips extended/desktop modules
# - Suitable for servers, VMs, or resource-constrained devices
{ lib, ... }:
let
  stateVersion = import ../configuration/stateversion.nix;
in
{
  imports = [
    # Boot-critical files from base_configuration/system/
    ../base_configuration/system/boot.nix
    ../base_configuration/system/core-packages.nix
    ../base_configuration/system/environment.nix
    ../base_configuration/system/localization.nix
    ../base_configuration/system/users.nix
    # Additional essential modules
    ../configuration/system/modules/hardware.nix
    ../configuration/system/modules/networking.nix
    ../configuration/system/modules/packages.nix
    ../configuration/system/modules/services.nix
    ../configuration/system/modules/ssh.nix
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

  nixpkgs.config.allowUnfree = lib.mkDefault true;

  system.stateVersion = lib.mkDefault stateVersion.system;
}
