# audio.nix
#
# Purpose: Configure PipeWire audio system with JACK and ALSA support
#
# This module:
# - Enables PipeWire with ALSA, PulseAudio, and JACK compatibility
# - Configures HDMI audio sample rates
# - Provides ALSA utilities for audio management
{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    alsa-utils
  ];

  services.pipewire = {
    enable = true;
    lowLatency = {
      enable = true;
      quantum = 64;
      rate = 48000;
    };
    alsa = {
      enable = true;
      support32Bit = true;
    };
    jack = {
      enable = true;
    };
    pulse.enable = true;
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
  };
}
