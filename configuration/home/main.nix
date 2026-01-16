# Main Home Configuration
#
# Purpose: Daily use applications and tools for Wayland environment
# Dependencies: minimal.nix, all main modules
# Related: minimal.nix, extras.nix
#
# This module:
# - Imports all main home modules
# - Provides Wayland desktop environment and applications
{
  pkgs,
  inputs,
  userConfig,
  hostPlatform,
  ...
}: {
  imports = [
    ./minimal.nix
    ./main/stylix.nix
    ./main/kde-apps.nix
    ./main/qt-gtk-config.nix
    ./main/fuzzel-config.nix
    ./main/kitty.nix
    ./main/fcitx5.nix
    ./main/zen-browser.nix
    ./main/zed.nix
    ./main/vscodium.nix
    ./main/screenshot.nix
    ./main/audio-control.nix
    ./main/syncthing.nix
    ./main/privacy.nix
    ./main/obs.nix
    ./main/vesktop.nix
    ./main/wayland/hyprland/hypr_config/hyprland.nix
    ./main/wayland/noctalia/noctalia_config/noctalia.nix
  ];

  home.packages = import ./main/packages.nix {inherit pkgs inputs hostPlatform userConfig;};
}
