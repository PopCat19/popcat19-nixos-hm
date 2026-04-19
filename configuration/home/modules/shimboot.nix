# shimboot-home-modules.nix
#
# Purpose: Pruned home modules for shimboot ChromeOS devices
#
# This module:
# - Includes essential desktop environment (Hyprland, Noctalia)
# - Provides core utilities (browser, terminal, editor)
# - Excludes heavy/resource-intensive apps (OBS, Ollama, generative tools, etc.)
{
  pkgs,
  inputs,
  userConfig,
  hostPlatform,
  ...
}:
{
  imports = [
    # Desktop environment
    ../hyprland/hyprland.nix
    ../noctalia/noctalia.nix
    ./stylix.nix
    ./fonts.nix

    # Essential applications
    ./zen-browser.nix
    ./kitty.nix
    ./micro.nix
    ./fuzzel-config.nix

    # Development tools (lightweight)
    ./git.nix
    ./lazygit.nix
    ./broot.nix
    ./starship.nix

    # Communication
    ./vesktop.nix

    # System utilities
    ./environment.nix
    ./services.nix
    ./home-files.nix
    ./systemd-services.nix
    ./kde-apps.nix
    ./qt-gtk-config.nix
    ./fcitx5.nix
    ./privacy.nix
    ./syncthing.nix
    ./screenshot.nix
    ./tmux.nix
    ./zathura.nix
    ./vscodium.nix
    ./glance.nix

    # Base home configuration
    ./home.nix
    ./wallpaper-sync.nix
  ];

  # Pruned packages for Chromebook (lighter than full packages.nix)
  home.packages = with pkgs; [
    # Terminal & shell
    fastfetch
    wl-clipboard
    gum

    # File management
    eza
    file
    tree

    # Development
    fd
    ripgrep
    git-lfs
    nodejs_22
    bun
    python3

    # System
    brightnessctl
    pavucontrol
    playerctl

    # Text editors
    helix

    # Media (lightweight)
    mpv

    # Networking
    localsend

    # Utilities
    jq
    coreutils-full
    util-linux
  ];

  # Link existing wallpaper directory for Noctalia
  home.file = {
    ".wallpaper" = {
      source = ../wallpaper;
      recursive = true;
    };
  };
}
