# home.nix
#
# Purpose: Home Manager configuration for the dedede0 host (shimboot)
# Pattern: explicit module imports, adapted from nsc popcat19 for pnh structure
{ lib, userConfig, ... }:
let
  stateVersion = import ../../stateversion.nix;
in
{
  home.username = userConfig.username;
  home.homeDirectory = lib.mkForce userConfig.directories.home;
  home.stateVersion = stateVersion.home;

  imports = [
    # Desktop environment
    ../../home/hyprland/hyprland.nix
    ../../home/noctalia/noctalia.nix
    ../../home/modules/stylix.nix
    ../../home/modules/fonts.nix

    # Applications
    ../../home/modules/zen-browser.nix
    ../../home/modules/kitty.nix
    ../../home/modules/micro.nix
    ../../home/modules/fuzzel-config.nix

    # Development
    ../../home/modules/git.nix
    ../../home/modules/lazygit.nix
    ../../home/modules/bookmarks.nix
    ../../home/modules/broot.nix
    ../../home/modules/starship.nix

    # Communication
    ../../home/modules/nixcord.nix

    # System utilities
    ../../home/modules/environment.nix
    ../../home/modules/services.nix
    ../../home/modules/home-files.nix
    ../../home/modules/systemd-services.nix
    ../../home/modules/dolphin.nix
    ../../home/modules/kde.nix
    ../../home/modules/qt-gtk-config.nix
    ../../home/modules/fcitx5.nix
    ../../home/modules/privacy.nix
    ../../home/modules/syncthing.nix
    ../../home/modules/screenshot.nix
    ../../home/modules/tmux.nix
    ../../home/modules/zathura.nix
    ../../home/modules/vscodium.nix
    ../../home/modules/glance.nix

    # Base
    ../../home/modules/home.nix
    ../../home/modules/wallpaper-sync.nix
  ];
}
