# configuration.nix
#
# Purpose: Minimal bootable NixOS base configuration
#
# This module:
# - Provides minimal bootable system with getty console
# - Imports only essential boot-critical modules
# - All other functionality delegated to profiles
{
  lib,
  pkgs,
  userConfig,
  ...
}:
{
  imports = [
    ./system/boot.nix
    ./system/localization.nix
    ../nix-options.nix
  ];

  # Enable getty on console
  services.getty.autologinUser = lib.mkDefault null;

  # Basic filesystem support
  boot.supportedFilesystems = [ "ext4" ];

  # Console font
  console.font = lib.mkDefault "Lat2-Terminus16";

  # Minimal system packages for convenience
  environment.systemPackages = with pkgs; [
    git
    gh
    ranger
    micro
  ];

  # Allow unfree packages (needed for some firmware)
  nixpkgs.config.allowUnfree = lib.mkDefault true;

  # Pass userConfig to all modules
  _module.args = {
    inherit userConfig;
  };
}
