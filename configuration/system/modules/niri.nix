# niri.nix
#
# Purpose: Configure Niri scrollable-tiling Wayland compositor
#
# This module:
# - Enables Niri compositor at system level
# - Enables UWSM for display manager integration
# - Configures XWayland support for X11 applications
# - Intentionally minimal for learning stock behavior
{ inputs, ... }:
{
  imports = [ inputs.niri.nixosModules.niri ];

  programs.uwsm.enable = true;

  services.xserver = {
    desktopManager.runXdgAutostartIfNone = true;
    enable = true;
    xkb.layout = "us";
  };
}
