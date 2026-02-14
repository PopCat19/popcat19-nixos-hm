# obs.nix
#
# Purpose: Configures OBS Studio with plugins for recording and streaming.
#
# This module:
# - Enables OBS Studio with plugin suite
# - Configures Wayland environment variables

{ pkgs, ... }:
let
  obs-plugins = with pkgs.obs-studio-plugins; [
    advanced-scene-switcher
    input-overlay
    obs-advanced-masks
    obs-pipewire-audio-capture
    obs-tuna
    obs-vkcapture
  ];
in
{
  home.sessionVariables = {
    OBS_WAYLAND = "1";
    XDG_SESSION_TYPE = "wayland";
  };
  programs.obs-studio = {
    enable = true;
    plugins = obs-plugins;
  };
}
