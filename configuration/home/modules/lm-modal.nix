# lm-modal.nix
#
# Purpose: Configure lm-modal Wayland LLM overlay
#
# This module:
# - Enables lm-modal via Home Manager
# - Configures endpoint for pi-gateway
# - Adds keybind for Hyprland

{ config, lib, inputs, hostPlatform, ... }:

{
  # Enable lm-modal service
  services.lm-modal = {
    enable = true;
    endpoint = "http://localhost:8088";
    model = null;  # Use pi-gateway default
    package = inputs.lm-modal.packages.${hostPlatform}.default;
  };

  # Add Hyprland keybind
  wayland.windowManager.hyprland.settings.bind = [
    "SUPER, P, exec, lm-modal"
  ];
}