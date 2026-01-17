# ThinkPad Hardware Configuration Module
#
# Purpose: Configure ThinkPad-specific hardware settings, including Intel UHD 620 graphics.
# Dependencies: intel-media-driver, vaapiIntel, vaapiVdpau, libvdpau-va-gl
# Related: system_modules/core_modules/hardware.nix
#
# This module:
# - Enables Intel UHD 620 graphics with appropriate drivers
# - Configures hardware acceleration for video decoding
# - Sets up Intel GuC/HuC firmware loading
{ pkgs, ... }:
{
  # ThinkPad-specific hardware settings
  hardware = {
    # Intel UHD 620 Graphics Configuration
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

  # Force Intel GuC/HuC firmware loading
  boot.kernelParams = [ "i915.enable_guc=2" ];
}
