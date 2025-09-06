# Home Manager configuration
{
  pkgs,
  config,
  system,
  lib,
  inputs,
  userConfig,
  ...
}: let
  # Get the hostname from userConfig
  hostname = userConfig.host.hostname;

  # Host-specific Hypr imports
  hyprImports =
    if hostname == "popcat19-nixos0" then [
      ./hosts/nixos0/hypr_config/hyprland.nix
      ./hosts/nixos0/hypr_config/hyprpanel.nix
    ] else if hostname == "popcat19-surface0" then [
      ./hosts/surface0/hypr_config/hyprland.nix
      ./hosts/surface0/hypr_config/hyprpanel.nix
    ] else if hostname == "popcat19-thinkpad0" then [
      ./hosts/thinkpad0/hypr_config/hyprland.nix
      ./hosts/thinkpad0/hypr_config/hyprpanel.nix
    ] else [
      # Fallback to shared home hypr config
      ./hypr_config/hyprland.nix
      ./hypr_config/hyprpanel-home.nix
    ];
in {
  # Basic home configuration
  home.username = userConfig.user.username;
  home.homeDirectory = userConfig.directories.home;
  home.stateVersion = "24.05";

  # Imports
  imports =
    [
      # Theme and UI
      ./home_modules/theme.nix
      ./home_modules/fonts.nix
      ./home_modules/screenshot.nix
      ./home_modules/zen-browser.nix
    ]
    ++ hyprImports
    ++ [
      # Core system
      ./home_modules/environment.nix
      ./home_modules/services.nix
      ./home_modules/home-files.nix
      ./home_modules/systemd-services.nix

      # Application and feature modules (minimal set for laptops)
      ./home_modules/kde.nix
      ./home_modules/qt-gtk-config.nix
      ./home_modules/fuzzel-config.nix
      ./home_modules/kitty.nix
      ./home_modules/fish.nix
      ./home_modules/starship.nix
      ./home_modules/micro.nix
      ./home_modules/fcitx5.nix
      ./home_modules/privacy.nix
      ./quickshell_config/quickshell.nix
      ./syncthing_config/home.nix
    ];

  # User packages
  home.packages = import ./home_modules/packages.nix { inherit pkgs inputs system userConfig; };
}
