# Minimal Profile Preset
#
# Purpose: Minimal configuration preset for limited hardware or testing
# Dependencies: configuration/system/configuration.nix (core only)
# Related: profiles/default/configuration.nix
#
# This preset:
# - Imports only essential system modules
# - Skips extended/desktop modules
# - Suitable for servers, VMs, or resource-constrained devices
{ inputs, ... }:
{
  imports = [
    ../../configuration/system/system_modules/environment.nix
    ../../configuration/system/system_modules/boot.nix
    ../../configuration/system/system_modules/networking.nix
    ../../configuration/system/system_modules/ssh.nix
    ../../configuration/system/system_modules/hardware.nix
    ../../configuration/system/system_modules/packages.nix
    ../../configuration/system/system_modules/core-packages.nix
    ../../configuration/system/system_modules/localization.nix
    ../../configuration/system/system_modules/users.nix
    ../../configuration/system/system_modules/services.nix
  ];

  # Minimal Nix settings
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    auto-optimise-store = true;
  };

  nix.gc = {
    automatic = true;
    dates = "03:00";
    options = "--delete-older-than 7d";
  };

  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "25.05";
}
