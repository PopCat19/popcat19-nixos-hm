# Home Manager configuration
{
  pkgs,
  config,
  system,
  lib,
  inputs,
  userConfig,
  ...
}:

let
  # Get the hostname from userConfig
  hostname = userConfig.host.hostname;
  
  # Determine which host-specific configuration to import
  hostHomeConfig = 
    if hostname == "popcat19-surface0" then ./hosts/surface0/home-packages.nix
    else if hostname == "popcat19-nixos0" then ./hosts/nixos0/home-packages.nix
    else null;
in

{
  # Basic home configuration
  home.username = userConfig.user.username;
  home.homeDirectory = userConfig.directories.home;
  home.stateVersion = "24.05";

  # Theme configuration
  # All theme-related configurations are imported from theme.nix

  imports = 
    # Import host-specific configuration if available
    (if hostHomeConfig != null then [ hostHomeConfig ] else []) ++
    
    # Default imports for hosts without specific configurations
    (if hostHomeConfig == null then [
      # Theme and UI
      ./home_modules/theme.nix
      ./home_modules/screenshot.nix
      ./home_modules/mangohud.nix
      ./hypr_config/hyprland.nix
      ./hypr_config/hyprpanel.nix
      
      # Core system
      ./home_modules/environment.nix
      ./home_modules/services.nix
      ./home_modules/ssh.nix
      ./home_modules/home-files.nix
      ./home_modules/systemd-services.nix

      # Application and feature modules
      ./home_modules/gaming.nix
      ./home_modules/development.nix
      ./home_modules/android-tools.nix
      ./home_modules/shimboot-project.nix
      ./home_modules/desktop-theme.nix
      ./home_modules/kde.nix
      ./home_modules/qt-gtk-config.nix
      ./home_modules/fuzzel-config.nix
      ./home_modules/kitty.nix
      ./home_modules/fish.nix
      ./home_modules/starship.nix
      ./home_modules/micro.nix
      ./home_modules/fcitx5.nix
      ./home_modules/rose-pine-checker.nix
      ./quickshell_config/quickshell.nix
      ./syncthing_config/home.nix
    ] else []);

  # User packages - only for hosts without specific configurations
  home.packages = 
    if hostHomeConfig == null 
    then import ./home_modules/packages.nix { inherit pkgs inputs system userConfig; }
    else [];
}
