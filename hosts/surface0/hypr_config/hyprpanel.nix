# Surface-specific HyprPanel Configuration
# ========================================
# This module imports the shared hyprpanel base configuration
# and adds Surface-specific bar.layouts for laptop single-screen setup
{
  config,
  pkgs,
  lib,
  ...
}: {
  # Import the shared hyprpanel base configuration
  imports = [
    ../../../hypr_config/hyprpanel-common.nix
  ];

  # Add Surface-specific bar.layouts configuration
  # This will override the base configuration's bar.layouts
  programs.hyprpanel.settings = {
    # Layout configuration - Configure bar layouts for Surface laptop single-screen setup
    "bar.layouts" = {
      "*" = {
        left = ["dashboard" "workspaces"];
        middle = ["media"];
        right = ["cputemp" "battery" "network" "bluetooth" "volume" "systray" "clock" "notifications"];
      };
    };
  };
}
