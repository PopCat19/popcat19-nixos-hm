# hyprland.nix
#
# Purpose: Configure Hyprland Wayland compositor with UWSM integration
#
# This module:
# - Enables Hyprland Wayland compositor
# - Configures XWayland support for X11 applications
# - Enables UWSM (Universal Wayland Session Manager)
_: {
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };

  programs.uwsm.enable = true;

  services.xserver = {
    desktopManager.runXdgAutostartIfNone = true;
    enable = true;
    xkb.layout = "us";
  };
}
