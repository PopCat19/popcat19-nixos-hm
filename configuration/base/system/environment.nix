# environment.nix
#
# Purpose: Configure system-level environment variables
#
# This module:
# - Sets system environment variables for Wayland and desktop environment
# - Defines default applications and configuration paths
{ lib, userConfig, ... }:
{
  environment.sessionVariables = {
    BROWSER = lib.mkDefault userConfig.defaultApps.browser.command;
    EDITOR = lib.mkDefault userConfig.defaultApps.editor.command;
    FILECHOOSER = lib.mkDefault userConfig.defaultApps.fileManager.package;
    NIXOS_CONFIG_DIR = lib.mkDefault "${userConfig.directories.home}/nixos-config";
    NIXOS_FLAKE_HOSTNAME = lib.mkDefault userConfig.hostname;
    NIXOS_OZONE_WL = lib.mkDefault "1";
    TERMINAL = lib.mkDefault userConfig.defaultApps.terminal.command;
    VISUAL = lib.mkDefault userConfig.defaultApps.editor.command;
    XDG_CURRENT_DESKTOP = lib.mkDefault "Hyprland";
    XDG_DESKTOP_PORTAL = lib.mkDefault "1";
    XDG_ICON_THEME = lib.mkDefault "Papirus-Dark";
    XDG_SESSION_TYPE = lib.mkDefault "wayland";
  };
}
