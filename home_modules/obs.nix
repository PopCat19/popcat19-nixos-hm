{ config, pkgs, ... }:

{
  # OBS Studio Configuration Module
  #
  # Purpose: Configure OBS Studio with comprehensive plugin suite for advanced recording and streaming.
  # Dependencies: obs-pipewire-audio-capture, obs-tuna, obs-vkcapture, input-overlay, obs-advanced-masks, advanced-scene-switcher
  # Related: environment.nix, theme.nix
  #
  # This module:
  # - Enables OBS Studio for screen recording and streaming
  # - Enables PipeWire audio capture plugin for better Wayland audio support
  # - Adds Tuna plugin for music metadata display
  # - Includes VKCapture for Vulkan-based screen capture
  # - Provides input overlay for controller/stream deck integration
  # - Adds advanced masks for visual effects
  # - Enables advanced scene switcher for automated workflows
  # - Configures optimal settings for screen capture and audio recording

  programs.obs-studio.enable = true;
  programs.obs-studio.plugins = with pkgs.obs-studio-plugins; [
    obs-pipewire-audio-capture
    obs-tuna
    obs-vkcapture
    input-overlay
    obs-advanced-masks
    advanced-scene-switcher
  ];

  # Environment variables for OBS on Wayland
  home.sessionVariables = {
    OBS_WAYLAND = "1";
    XDG_SESSION_TYPE = "wayland";
  };

  # Additional OBS plugins (obs-studio itself is handled by programs.obs-studio.enable)
  home.packages = with pkgs; [
    obs-studio-plugins.obs-pipewire-audio-capture
    obs-studio-plugins.obs-tuna
    obs-studio-plugins.obs-vkcapture
    obs-studio-plugins.input-overlay
    obs-studio-plugins.obs-advanced-masks
    obs-studio-plugins.advanced-scene-switcher
  ];
}