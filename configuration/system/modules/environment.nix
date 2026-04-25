# environment.nix
#
# Purpose: Configure system-level environment variables
#
# This module:
# - Sets system environment variables for Wayland and desktop environment
# - Defines default applications and configuration paths
#
# Note for shimboot: Base config sets EDITOR/VISUAL with mkOverride 500.
# This module's normal assignment (100) wins, so profile values take precedence.
# Redundancy is intentional for non-shimboot profiles that need these vars.
{ userConfig, ... }:
{
  environment.sessionVariables = {
    BROWSER = userConfig.defaultApps.browser.command;
    EDITOR = userConfig.defaultApps.editor.command;
    FILECHOOSER = userConfig.defaultApps.fileManager.package;
    NIXOS_CONFIG_DIR = "${userConfig.directories.home}/popcat19-nixos-hm";
    NIXOS_FLAKE_HOSTNAME = userConfig.hostname;
    NIXOS_OZONE_WL = "1";
    TERMINAL = userConfig.defaultApps.terminal.command;
    VISUAL = userConfig.defaultApps.editor.command;
    WEBKIT_DISABLE_COMPOSITING_MODE = "1";
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_DESKTOP_PORTAL = "1";
    XDG_ICON_THEME = "Papirus-Dark";
    XDG_SESSION_TYPE = "wayland";
  };
}
