# Window Manager Configuration Module
#
# Purpose: Configure Hyprland Wayland compositor with UWSM integration
# Dependencies: hyprland, uwsm, xwayland
# Related: greeter.nix, xdg.nix
#
# This module:
# - Enables Hyprland Wayland compositor
# - Configures XWayland support for X11 applications
# - Enables UWSM (Universal Wayland Session Manager)
# - Sets up X server for X11 compatibility
{
  pkgs,
  ...
}: {
  services.xserver = {
    enable = true;
    xkb.layout = "us";
    desktopManager.runXdgAutostartIfNone = true;
  };

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    withUWSM = true;
  };
  programs.uwsm.enable = true;
}