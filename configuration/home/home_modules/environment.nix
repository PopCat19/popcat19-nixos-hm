# User Environment Configuration Module
#
# Purpose: Configure user-specific environment variables and session settings
# Dependencies: lib, fcitx5
# Related: system_modules/environment.nix, qt-gtk-config.nix
#
# This module:
# - Sets user environment variables for applications and Wayland support
# - Configures input method framework (fcitx5) for internationalization
# - Defines default applications and GTK/Qt theming variables
# - Manages session PATH and application-specific settings
{
  lib,
  userConfig,
  config,
  ...
}: {
  home.sessionVariables = {
    XDG_ICON_THEME = "Papirus-Dark";

    ELECTRON_OZONE_PLATFORM_HINT = "wayland";
    MOZ_ENABLE_WAYLAND = "1";
    GTK_USE_PORTAL = "1";

    EDITOR = userConfig.defaultApps.editor.command;
    VISUAL = userConfig.defaultApps.editor.command;
    BROWSER = userConfig.defaultApps.browser.command;
    TERMINAL = userConfig.defaultApps.terminal.command;
    FILE_MANAGER = userConfig.defaultApps.fileManager.command;
    
    WEBKIT_DISABLE_COMPOSITING_MODE = "1";

    GTK_IM_MODULE = lib.mkForce "fcitx5";
    QT_IM_MODULE = lib.mkForce "fcitx5";
    XMODIFIERS = lib.mkForce "@im=fcitx5";
    GTK4_IM_MODULE = "fcitx5";

    GDK_SCALE = "1";
  };

  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.npm-global/bin"
  ];
}
