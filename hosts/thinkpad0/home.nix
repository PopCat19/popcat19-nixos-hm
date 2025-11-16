# Home Manager configuration for thinkpad0 (copied from nixos0)
{
  pkgs,
  config,
  system,
  lib,
  inputs,
  userConfig,
  ...
}: {
  # Basic home configuration
  home.username = userConfig.user.username;
  home.homeDirectory = userConfig.directories.home;
  home.stateVersion = "24.05";

  # Imports (all modules for thinkpad0, including generative AI)
  imports = [
    ./hypr_config/hyprland.nix
    ./hypr_config/hyprpanel.nix
    ../../home_modules/theme.nix
    ../../home_modules/fonts.nix
    ../../home_modules/screenshot.nix
    ../../home_modules/zen-browser.nix
    ../../home_modules/generative.nix
    ../../home_modules/environment.nix
    ../../home_modules/services.nix
    ../../home_modules/home-files.nix
    ../../home_modules/systemd-services.nix
    ../../home_modules/kde-apps.nix
    ../../home_modules/qt-gtk-config.nix
    ../../home_modules/fuzzel-config.nix
    ../../home_modules/kitty.nix
    ../../home_modules/fish.nix
    ../../home_modules/starship.nix
    ../../home_modules/micro.nix
    ../../home_modules/fcitx5.nix
    ../../home_modules/mangohud.nix
    ../../home_modules/privacy.nix
../../home_modules/obs.nix
    ../../quickshell_config/quickshell.nix
    ../../syncthing_config/home.nix
  ];

  # Use the centralized packages list from home_modules/packages.nix.
  # This is the canonical source; per-host package overrides can still be
  # implemented here if necessary.
  home.packages = import ../../home_modules/packages.nix {inherit pkgs inputs system userConfig;};
}
