# Home Manager package configuration

{
  pkgs,
  inputs,
  system,
  userConfig,
}:

let
  # Import architecture-specific modules
  x86_64Packages = import ./x86_64-packages.nix { inherit pkgs; };
  aarch64Packages = import ./aarch64-packages.nix { inherit pkgs; };

  # Architecture detection
  isX86_64 = system == "x86_64-linux";
  isAarch64 = system == "aarch64-linux";

  # Select appropriate packages based on architecture
  archSpecificPackages = if isX86_64 then x86_64Packages else aarch64Packages;

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
  youtube-music
  
  # Hyprland Essentials
  hyprpanel
  hyprshade
  hyprpolkitagent
  hyprutils
  
  # Communication
  vesktop
  keepassxc
  
  # System Monitoring
  fastfetch
  
  # Audio & Hardware Control
  pavucontrol
  playerctl
] ++ archSpecificPackages ++ [
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
   nixfmt-rfc-style

   # Neovim and Language Servers
   neovim
   
   pyright
   lua-language-server
   nodePackages_latest.typescript-language-server
   nodePackages_latest.vscode-langservers-extracted

   # Code Formatters
   black
   prettierd

   # Development Tools
   ripgrep
   fd
   lazygit
]
