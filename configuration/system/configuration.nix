# System Configuration Module
#
# Purpose: Core NixOS configuration for nixos-config base system
# Dependencies: All base system_modules, user-config.nix
# Related: configuration/home/home.nix, configuration/system/system-extended.nix, user-config.nix
#
# This module:
# - Imports all base system modules
# - Configures Nix settings and binary caches
# - Enables core system functionality
# - Sets system state version
{
  config,
  pkgs,
  lib,
  ...
}: let
  userConfig = import ../../configuration/user-config.nix {};
in {
  imports = [
    ./system_modules/environment.nix
    ./system_modules/fish.nix
    ./system_modules/boot.nix
    ./system_modules/networking.nix
    ./system_modules/ssh.nix
    ./system_modules/hardware.nix
    ./system_modules/packages.nix
    ./system_modules/core-packages.nix
    ./system_modules/localization.nix
    ./system_modules/users.nix
    ./system_modules/services.nix
    ./system_modules/display.nix
    ./system_modules/noctalia.nix
    ./system_modules/audio.nix
    ./system_modules/virtualisation.nix
    ./system_modules/fonts.nix
    ./system_modules/gnome-keyring.nix
  ];

  _module.args.userConfig = userConfig;

  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
    trusted-users = lib.mkAfter ["root" "${userConfig.user.username}"];
    # Add binary caches here as needed
    # substituters = lib.mkAfter ["https://cache.nixos.org/"];
    # trusted-public-keys = lib.mkAfter ["cache.nixos.org-1:6NCHdD59X431o0jWzmge3Qi8TWxF6bXlEAEaLLJgI="];

    # Enable store optimization at build time
    auto-optimise-store = true; # Hardlink duplicate files
    min-free = 0; # Don't reserve space
  };

  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "25.05";
}