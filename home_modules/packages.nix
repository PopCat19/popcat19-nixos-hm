# Home Manager package configuration

{
  pkgs,
  inputs,
  system,
  userConfig,
}:

let
  # Architecture detection
  isX86_64 = system == "x86_64-linux";
  isAarch64 = system == "aarch64-linux";
  
  # Helper functions
  onlyX86_64 = packages: if isX86_64 then packages else [];
  onlyAarch64 = packages: if isAarch64 then packages else [];
  
  # Architecture-specific packages
  systemMonitoring = if isX86_64 then [ pkgs.btop-rocm ] else [ pkgs.btop ];
  hardwareControl = if isX86_64 then [
    pkgs.ddcui
    pkgs.openrgb-with-all-plugins
  ] else [];
  
in
with pkgs;
[
  # Terminal & Core Tools
  kitty
  fuzzel
  micro
  eza
  starship
  wl-clipboard
  pkgs.nur.repos.charmbracelet.crush
  
  # Browsers
  firefox
] ++ [
  
  # Media
  mpv
  audacious
  audacious-plugins
  pureref
  
  # Hyprland Essentials
  hyprpanel
  hyprshade
  hyprpolkitagent
  hyprutils
  
  # Communication
  vesktop
  keepassxc
  
  # System Monitoring
] ++ systemMonitoring ++ [
  fastfetch
  
  # Audio & Hardware Control
  pavucontrol
  playerctl
] ++ hardwareControl ++ [
  glances
  
  # File Sharing
  localsend
  zrok
  
  # Notifications
  dunst
  libnotify
  zenity
  
  # Development Editors
  vscodium
  zed-editor
  
  # Nix Development
  nil
  nixd
] ++
# Architecture-specific packages
onlyX86_64 [
  # x86_64-specific packages
] ++
onlyAarch64 [
  # ARM64-specific packages
]
