# thinkpad0-specific HyprPanel Configuration (copied from nixos0)
{ config, pkgs, lib, ... }:

{
  # Import the shared hyprpanel base configuration
  imports = [
    ../../../hypr_config/hyprpanel-common.nix
  ];

  # Add thinkpad0-specific bar.layouts configuration
  # This will override the base configuration's bar.layouts
  programs.hyprpanel.settings = {
    # Layout configuration - Configure bar layouts for a typical laptop setup
    "bar.layouts" = {
      "*" = {
        left = [ "workspaces" "dashboard" ];
        middle = [ ];
        right = [ "battery" "network" "volume" "systray" "clock" "notifications" ];
      };
    };
  };
}