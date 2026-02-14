# audio.nix
#
# Purpose: Configure PipeWire audio system with HDMI support
#
# This module:
# - Enables PipeWire with ALSA and PulseAudio compatibility
# - Configures HDMI audio sample rates
# - Provides ALSA utilities for audio management
{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    alsa-utils
  ];

  services.pipewire = {
    enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    extraConfig.pipewire."91-hdmi-audio" = {
      "context.properties" = {
        "default.clock.allowed-rates" = [
          44100
          48000
          96000
        ];
        "default.clock.rate" = 48000;
      };
    };
    pulse.enable = true;
  };
}
