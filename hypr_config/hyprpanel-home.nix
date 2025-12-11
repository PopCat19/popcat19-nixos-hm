# home-hyprpanel.nix
# HyprPanel configuration with Rose Pine theme integration
# This module imports the common configuration and adds bar layouts
# Based on documentation: https://hyprpanel.com/
{userConfig, ...}: {
  # Import the common hyprpanel base configuration
  imports = [
    ./hyprpanel-common.nix
  ];

  # Add bar layouts configuration for standard desktop setup
  programs.hyprpanel.settings = {
    # Layout configuration - Configure bar layouts for standard desktop setup
    "bar.layouts" = {
      "*" = {
        left = ["dashboard" "workspaces" "media"];
        middle = [];
        right = ["cputemp" "battery" "network" "bluetooth" "volume" "systray" "clock" "notifications"];
      };
    };
  };
}
