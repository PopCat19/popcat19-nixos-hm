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
  pkgs,
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
    ../system/modules/stylix-lightdm.nix
  ];

  # Re-export userConfig for shimboot modules
  _module.args.userConfig = userConfig;

  home-manager.users.${userConfig.username} = {
    imports = [ ../home/modules/shimboot.nix ];

    # Add LLM agents packages from numtide
    home.packages = [
      inputs.llm-agents.packages.${pkgs.system}.opencode
      inputs.llm-agents.packages.${pkgs.system}.kilocode-cli
    ];
  };
}
