# niri.nix
#
# Purpose: Configure Niri scrollable-tiling Wayland compositor
#
# This module:
# - Enables Niri compositor at system level
# - Enables UWSM for display manager integration
# - Configures XWayland support for X11 applications
# - Intentionally minimal for learning stock behavior
{ inputs, pkgs, ... }:
{
  imports = [ inputs.niri.nixosModules.niri ];

  programs.niri.package =
    inputs.niri.packages.${pkgs.stdenv.hostPlatform.system}.niri-stable.overrideAttrs
      {
        doCheck = false;
      };

  programs.uwsm.enable = true;

  services.xserver = {
    desktopManager.runXdgAutostartIfNone = true;
    enable = true;
    xkb.layout = "us";
  };
}
