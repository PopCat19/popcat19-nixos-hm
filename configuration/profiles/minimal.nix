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
  stateVersion = import ../stateversion.nix;
in
{
  imports = [
    # Boot-critical files from base/system/
    ../base/system/boot.nix
    ../base/system/core-packages.nix
    ../base/system/environment.nix
    ../base/system/localization.nix
    ../base/system/users.nix
    # Additional essential modules
    ../system/modules/hardware.nix
    ../system/modules/networking.nix
    ../system/modules/packages.nix
    ../system/modules/services.nix
    ../system/modules/ssh.nix
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
