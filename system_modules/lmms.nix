# LMMS (Linux Multimedia Studio) Configuration Module
#
# Purpose: Configure LMMS digital audio workstation with proper audio backend support
# Dependencies: pipewire, jack2, alsa-lib, carla, fftwFloat, fltk13, fluidsynth, libsamplerate, libsndfile
# Related: audio.nix, packages.nix
#
# This module:
# - Enables LMMS DAW with comprehensive audio plugin support
# - Configures JACK audio server integration for low-latency audio
# - Provides Carla plugin host for VST/LV2 plugin support
# - Ensures proper audio group permissions for real-time audio processing
# - Includes essential audio libraries and codecs for music production
{pkgs, ...}: {

  # Audio system configuration for LMMS
  services.pipewire = {
    # Enable JACK compatibility through PipeWire
    jack.enable = true;
    
    # Additional JACK configuration for LMMS
    extraConfig.jack."21-lmms-jack" = {
      "context.properties" = {
        # Default JACK settings for LMMS
        "default.clock.rate" = 48000;
        "default.clock.allowed-rates" = [44100 48000 96000];
        "default.clock.quantum" = 256;
        "default.clock.min-quantum" = 32;
        "default.clock.max-quantum" = 8192;
      };
    };
  };

  # Real-time audio configuration
  security.rtkit.enable = true;
  
  # System packages for LMMS and audio production
  environment.systemPackages = with pkgs; [
    # LMMS DAW
    lmms
    
    # Audio plugin hosts and frameworks
    carla
    calf
    
    # Audio development libraries
    fftwFloat
    libsamplerate
    libsndfile
    libsoundio
    
    # MIDI utilities
    a2jmidid
    qjackctl
    
    # Additional audio tools
    audacity
    sox
    
    # JACK utilities
    jack2
    
    # Audio format support
    flac
    lame
    libvorbis
    
    # SoundFont support
    fluidsynth
    soundfont-fluid
    
    # Real-time audio monitoring
    pasystray
  ];

  # Environment variables for LMMS
  environment.sessionVariables = {
    # Ensure LMMS uses JACK audio backend
    "LMMS_AUDIO_BACKEND" = "jack";
    
    # Plugin paths
    "LADSPA_PATH" = "/run/current-system/sw/lib/ladspa";
    "LV2_PATH" = "/run/current-system/sw/lib/lv2";
    "VST_PATH" = "/run/current-system/sw/lib/vst";
    
    # JACK configuration
    "JACK_DEFAULT_SERVER" = "default";
  };

  # System limits for real-time audio processing
  security.pam.loginLimits = [
    {
      domain = "@audio";
      type = "-";
      item = "rtprio";
      value = "95";
    }
    {
      domain = "@audio";
      type = "-";
      item = "memlock";
      value = "unlimited";
    }
  ];

  # Optional: Enable JACK service for system-wide JACK server
  # Uncomment if you want JACK to start automatically at boot
  # services.jack = {
  #   jackd = {
  #     enable = true;
  #     options = [
  #       "-d alsa"
  #       "-d hw:0"
  #       "-r 48000"
  #       "-p 256"
  #       "-n 3"
  #     ];
  #   };
  # };

  # Udev rules for audio devices
  services.udev.extraRules = ''
    # USB MIDI devices
    SUBSYSTEM=="usb", ENV{ID_USB_INTERFACE_NUM}=="00", ATTRS{idVendor}=="*", ATTRS{idProduct}=="*", MODE="0666", GROUP="audio"
    
    # Audio interfaces
    SUBSYSTEM=="sound", MODE="0666", GROUP="audio"
    KERNEL=="snd/*", MODE="0666", GROUP="audio"
  '';
}