# Minimal System Configuration
#
# Purpose: Core system configuration for boot to TTY with network and users
# Dependencies: All minimal modules
# Related: main.nix, extras.nix
#
# This module:
# - Imports all minimal system modules
# - Provides base system functionality
{...}: {
  imports = [
    ./minimal/boot.nix
    ./minimal/networking.nix
    ./minimal/ssh.nix
    ./minimal/hardware.nix
    ./minimal/users.nix
    ./minimal/services.nix
    ./minimal/environment.nix
    ./minimal/fish.nix
    ./minimal/localization.nix
    ./minimal/core-packages.nix
    ./minimal/fonts.nix
    ./minimal/audio.nix
    ./minimal/virtualisation.nix
  ];
}
