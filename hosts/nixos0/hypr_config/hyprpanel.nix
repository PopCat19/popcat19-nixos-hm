# nixos0-specific HyprPanel Configuration
# ========================================
# This module imports the shared hyprpanel base configuration
# and adds nixos0-specific bar.layouts for desktop dual-monitor setup

{ config, pkgs, lib, ... }:

{
  # Import the shared hyprpanel base configuration
  imports = [
    ../../../hypr_config/hyprpanel-base.nix
  ];

  # Add nixos0-specific bar.layouts configuration
  # This will override the base configuration's bar.layouts
  programs.hyprpanel.settings = {
    # Layout configuration - Configure bar layouts for nixos0 desktop dual-monitor setup
    "bar.layouts" = {
      "*" = {
        left = [ "dashboard" "workspaces" "media" ];
        middle = [ ];
        right = [ "cputemp" "network" "bluetooth" "volume" "systray" "clock" "notifications" ];
      };
    };
  };
}