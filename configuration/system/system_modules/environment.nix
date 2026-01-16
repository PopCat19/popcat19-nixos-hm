# System Environment Configuration Module
#
# Purpose: Configure system-level environment variables
# Dependencies: None
# Related: home_modules/environment.nix, greeter.nix
#
# This module:
# - Sets system environment variables for Wayland and desktop environment
# - Defines default applications and configuration paths
{userConfig, ...}: {
  environment.sessionVariables = {
    XDG_SESSION_TYPE = "wayland";
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_DESKTOP_PORTAL = "1";
    NIXOS_OZONE_WL = "1";

    XDG_ICON_THEME = "Papirus-Dark";

    TERMINAL = userConfig.defaultApps.terminal.command;
    EDITOR = userConfig.defaultApps.editor.command;
    VISUAL = userConfig.defaultApps.editor.command;
    BROWSER = userConfig.defaultApps.browser.command;
    FILECHOOSER = userConfig.defaultApps.fileManager.package;

    NIXOS_CONFIG_DIR = "${userConfig.directories.home}/nixos-config";
    NIXOS_FLAKE_HOSTNAME = userConfig.host.hostname;
  };
}
