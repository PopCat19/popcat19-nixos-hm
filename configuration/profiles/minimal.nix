# minimal.nix
#
# Purpose: Minimal configuration preset for limited hardware or testing
#
# This profile:
# - Imports only essential system modules
# - Skips extended/desktop modules
# - Suitable for servers, VMs, or resource-constrained devices
{ lib, userConfig, ... }:
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
    # Centralized nix configuration
    ../nix-options.nix
    # Additional essential modules
    ../system/modules/hardware.nix
    ../system/modules/networking.nix
    ../system/modules/packages.nix
    ../system/modules/services.nix
    ../system/modules/ssh.nix
  ];

  _module.args = {
    inherit userConfig;
  };

  # Override gc options for minimal systems
  nix.gc.options = "--delete-older-than 7d";

  system.stateVersion = lib.mkDefault stateVersion.system;
}
