# shimboot.nix
#
# Purpose: Shimboot profile preset for ChromeOS devices with dedede board
#
# This profile:
# - Imports shimboot chromeos base configuration (includes boot, fs, hw, users, nix settings, display-manager, services, audio, networking, hyprland, fish, fonts, power-management, xdg-portals)
# - Configures Hyprland with Noctalia shell via home-manager
# - Includes Zen Browser and user environment
# - Sets up LLM agents (opencode, kilocode)
# - Adds Stylix theming support
{
  userConfig,
  inputs,
  ...
}:
{
  imports = [
    # Shimboot chromeos base configuration - already includes:
    # - boot.nix, filesystems.nix, networking.nix
    # - audio.nix, display-manager.nix, hyprland.nix
    # - fish.nix, fonts.nix, users.nix, services.nix
    # - xdg-portals.nix, power-management.nix, security.nix
    # - nix-options.nix, localization.nix, environment.nix
    inputs.shimboot.nixosModules.chromeos

    # Additional modules not in base
    ../system/modules/ssh.nix
    ../system/modules/syncthing.nix
    # ../system/modules/stylix-lightdm.nix # redundant
    ../system/modules/gnome-keyring.nix
    # ../system/modules/hyprland.nix # don't use uwsm for shimboot
    ../system/modules/noctalia.nix
    ../system/packages.nix
    # ../system/modules/services.nix # shimboot managed
    ../system/modules/xdg.nix
    # ../system/modules/programs.nix # disable for now, shimboot incl. fish already
    ../system/modules/environment.nix
    ../system/modules/dconf.nix
  ];

  # Re-export userConfig for shimboot modules
  _module.args.userConfig = userConfig;

  # home.nix from host directory handles home-manager imports
}
