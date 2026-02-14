# hardware.nix
#
# Purpose: Hardware configuration for ThinkPad with Intel UHD 620 graphics
#
# This module:
# - Enables Intel graphics with hardware acceleration drivers
# - Configures Intel GuC/HuC firmware loading
{ pkgs, ... }:
{
  hardware = {
    graphics = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver
        intel-vaapi-driver
        libva-vdpau-driver
        libvdpau-va-gl
      ];
    };
  };

  boot.kernelParams = [ "i915.enable_guc=2" ];
}
