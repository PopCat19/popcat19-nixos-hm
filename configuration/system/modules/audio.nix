# audio.nix
#
# Purpose: Configure PipeWire audio system with JACK and ALSA support
#
# This module:
# - Enables PipeWire with ALSA, PulseAudio, and JACK compatibility
# - Configures HDMI audio sample rates
# - Sets realtime + memlock limits for pro audio (PipeWire + EasyEffects)
# - Forces quantum 512/48000 to avoid USB audio crackling
# - Provides ALSA utilities for audio management
{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    alsa-utils
  ];

  # Pro-audio memlock + realtime: PipeWire + EasyEffects DSP chain can exceed
  # the default 8MB locked memory limit, causing buffer allocation failures
  # (EIO / -5) when new streams try to link through the processing chain.
  security.pam.loginLimits = [
    {
      domain = "@audio";
      item = "memlock";
      type = "-";
      value = "unlimited";
    }
    {
      domain = "@audio";
      item = "rtprio";
      type = "-";
      value = "99";
    }
    {
      domain = "@audio";
      item = "nice";
      type = "-";
      value = "-19";
    }
  ];

  services.pipewire = {
    enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    jack = {
      enable = true;
    };
    pulse.enable = true;
    wireplumber.enable = true;

    # Quantum 512/48000 = ~10.7ms. 64 (1.3ms) from pipewireLowLatency was
    # too aggressive for USB audio + EasyEffects DSP, causing crackling.
    extraConfig.pipewire."92-quantum" = {
      "context.properties" = {
        "default.clock.min-quantum" = 512;
        "default.clock.quantum" = 512;
        "default.clock.max-quantum" = 1024;
      };
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
  };
}
