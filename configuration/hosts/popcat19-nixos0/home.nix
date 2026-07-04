# home.nix
#
# Purpose: Home Manager configuration for the nixos0 host
#
# This module:
# - Sets up home configuration from userConfig
# - Imports central home configuration
# - Applies host-specific monitor settings
# - Creates a headless FHD output for Sunshine streaming (scripts in configuration.nix toggle DPMS)
{ lib, userConfig, ... }:
let
  stateVersion = import ../../stateversion.nix;
in
{
  home.username = userConfig.username;
  home.homeDirectory = lib.mkForce userConfig.directories.home;
  home.stateVersion = stateVersion.home;

  imports = [
    ../../home/modules
  ];

  home.file.".config/hypr/monitors.conf".source = ./hyprland/monitors.conf;

  wayland.windowManager.hyprland.settings = {
    "exec-once" = [
      "hyprctl output create headless HEADLESS-SUNSHINE"
      "hyprctl dispatch moveworkspacetomonitor 10 HEADLESS-SUNSHINE"
    ];
  };

  # Toggle Super+C for hjkl mouse emulation. Requires services.kanataUdev.enable
  # in configuration.nix so /dev/uinput is accessible to the user service.
  programs.kanata.enable = true;

  # Seed-once OBS profile: Advanced mode, AMD VAAPI H.264 stream (CBR 8000)
  # and AV1 record (CQP 22). Files are seeded only if absent, so UI edits in
  # OBS persist across rebuilds. Re-seed by deleting the profile files.
  programs.obs-studio.streamingProfile = {
    enable = true;
    vaapiDevice = "/dev/dri/by-path/pci-0000:12:00.0-render";
    streamBitrate = 8000;
    recordQp = 22;
  };
}
