{config, ...}: {
  # **CONFIGURATION FILE MANAGEMENT**
  # Manages symlinks for configuration files.
  home.file.".config/hypr" = {
    source = ../main/wayland/hyprland/hypr_config;
    recursive = true;
  };

  # Copy wallpaper directory for Noctalia wallpaper management
  home.file."wallpaper" = {
    source = ../wallpaper;
    recursive = true;
  };

  # NPM global configuration for reproducible package management
  home.file.".npmrc".text = ''
    prefix=${config.home.homeDirectory}/.npm-global
  '';
}
