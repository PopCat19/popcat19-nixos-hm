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
#
# Note: Base config uses mkOverride 500 for common settings (EDITOR, dconf, etc.)
# Profile can override with normal assignment (100) if needed.
{
  lib,
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
    # - dconf (via display-manager.nix with mkOverride 500)
    inputs.shimboot.nixosModules.chromeos

    # Additional modules not in base
    ../system/modules/ssh.nix
    ../system/modules/syncthing.nix
    ../system/modules/gnome-keyring.nix
    ../system/modules/noctalia.nix
    ../system/packages.nix
    ../system/modules/xdg.nix
    ../system/modules/environment.nix
  ];

  # Re-export userConfig for shimboot modules
  _module.args.userConfig = userConfig;

  # Override NIXOS_CONFIG_DIR for pnh repo
  # (shimboot base would set it to nixos-shimboot via its userConfig.env)
  environment.sessionVariables.NIXOS_CONFIG_DIR = lib.mkForce "${userConfig.directories.home}/popcat19-nixos-hm";

  # home.nix from host directory handles home-manager imports
}
