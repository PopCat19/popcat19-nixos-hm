# Aggregated system modules to simplify per-host imports
{ }:
[
  # Core modules
  ./core_modules/boot.nix
  ./core_modules/hardware.nix
  ./core_modules/networking.nix
  ./core_modules/users.nix

  # System feature modules
  ./localization.nix
  ./services.nix
  ./display.nix
  ./audio.nix
  ./virtualisation.nix
  ./programs.nix
  ./environment.nix
  ./core-packages.nix
  ./packages.nix
  ./fonts.nix
  ./tablet.nix
  ./openrgb.nix
  ./privacy.nix
  ./gnome-keyring.nix
  ./vpn.nix
]