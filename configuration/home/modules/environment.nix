# environment.nix
#
# Purpose: Configure user-specific environment variables and session settings
#
# This module:
# - Sets user environment variables for applications and Wayland support
# - Configures input method framework (fcitx5) for internationalization
# - Defines default applications and GTK/Qt theming variables
let
  imModule = "fcitx5";
in
{
  lib,
  userConfig,
  ...
}:
{
  home.sessionVariables = {
    BROWSER = userConfig.defaultApps.browser.command;
    EDITOR = userConfig.defaultApps.editor.command;
    ELECTRON_OZONE_PLATFORM_HINT = "wayland";
    FILE_MANAGER = userConfig.defaultApps.fileManager.command;
    GDK_SCALE = "1";
    GTK4_IM_MODULE = imModule;
    GTK_IM_MODULE = lib.mkForce imModule;
    GTK_USE_PORTAL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    QT_IM_MODULE = lib.mkForce imModule;
    TERMINAL = userConfig.defaultApps.terminal.command;
    VISUAL = userConfig.defaultApps.editor.command;
    WEBKIT_DISABLE_COMPOSITING_MODE = "1";
    XDG_ICON_THEME = "Papirus-Dark";
    XMODIFIERS = lib.mkForce "@im=${imModule}";
  };

  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.npm-global/bin"
    "$HOME/bin"
  ];
}
