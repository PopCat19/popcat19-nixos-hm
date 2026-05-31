# audio.nix
#
# Purpose: Configure PipeWire audio system with JACK and ALSA support
#
# This module:
# - Enables PipeWire with ALSA, PulseAudio, and JACK compatibility
# - Configures HDMI audio sample rates
# - Sets realtime + memlock limits for pro audio (PipeWire + EasyEffects)
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
    lowLatency = {
      enable = true;
      # 256/48000 = ~5.3ms. 64 (1.3ms) was too aggressive and caused buffer
      # negotiation failures with the Razer Kraken V4 Pro + EasyEffects chain.
      quantum = 256;
      rate = 48000;
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
