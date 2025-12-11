{
  config,
  pkgs,
  lib,
  ...
}: let
  wallpaper = import ./wallpaper.nix {inherit lib pkgs;};
in {
  imports = [
    ./modules/colors.nix
    ./modules/environment.nix
    ./modules/autostart.nix
    ./modules/general.nix
    ./modules/animations.nix
    ./modules/keybinds.nix
    ./modules/window-rules.nix
    ./modules/hyprlock.nix
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    package = pkgs.hyprland;

    settings = {
      source = [
        "~/.config/hypr/monitors.conf"
        "~/.config/hypr/userprefs.conf"
      ];
    };
  };

  home.file = {
    ".config/hypr/monitors.conf".source = ./monitors.conf;
    ".config/hypr/userprefs.conf".source = ./userprefs.conf;
    ".config/hypr/hyprpaper.conf".source = wallpaper.hyprpaperConf;
    ".config/hypr/shaders" = {
      source = ./shaders;
      recursive = true;
    };
  };
}
