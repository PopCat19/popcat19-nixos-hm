{
  lib,
  userConfig,
  config,
  ...
}: {
  # **ENVIRONMENT VARIABLES**
  # Defines user-specific environment variables for various applications.
  home.sessionVariables = {
    # Icon theme
    XDG_ICON_THEME = "Papirus-Dark";

    # Application environment variables
    ELECTRON_OZONE_PLATFORM_HINT = "wayland";
    MOZ_ENABLE_WAYLAND = "1";
    GTK_USE_PORTAL = "1";

    # Default applications
    EDITOR = userConfig.defaultApps.editor.command; # Default terminal editor.
    VISUAL = userConfig.defaultApps.editor.command; # Visual editor alias.
    BROWSER = userConfig.defaultApps.browser.command; # Default web browser.
    TERMINAL = userConfig.defaultApps.terminal.command;
    FILE_MANAGER = userConfig.defaultApps.fileManager.command;
    
    # Ensure thumbnails work properly
    WEBKIT_DISABLE_COMPOSITING_MODE = "1";

    # Input Method (fcitx5) with Wayland support
    GTK_IM_MODULE = lib.mkForce "fcitx5";
    QT_IM_MODULE = lib.mkForce "fcitx5";
    XMODIFIERS = lib.mkForce "@im=fcitx5";
    GTK4_IM_MODULE = "fcitx5";

    # GTK/scale defaults
    GDK_SCALE = "1";
  };

  # Add local bin to PATH
  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.npm-global/bin"
  ];
}
