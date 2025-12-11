# Noctalia Home Manager Configuration Module
#
# Purpose: Configure Noctalia shell widgets and settings for the user
# Dependencies: inputs.noctalia (flake input), home-manager
# Related: system_modules/noctalia.nix
#
# This module:
# - Imports Noctalia home manager module
# - Configures widget layout with workspace before clock
# - Sets up basic Noctalia settings and appearance
# - Provides customized bar configuration
{
  config,
  pkgs,
  lib,
  inputs,
  userConfig,
  ...
}: {
  imports = [
    inputs.noctalia.homeModules.default
  ];

  programs.noctalia-shell = {
    enable = true;

    # Configure Noctalia settings with workspace widget before clock
    settings = {
      bar = {
        position = "top";
        density = "default";
        showCapsule = true;
        widgets = {
          left = [
            # {
            #   icon = "rocket";
            #   id = "CustomButton";
            #   leftClickExec = "noctalia-shell ipc call launcher toggle";
            # }
            {
              id = "Workspace";
              hideUnoccupied = false;
              labelMode = "name";
            }
            # {
            #   id = "ActiveWindow";
            # }
            {
              id = "MediaMini";
            }
          ];
          center = [
          ];
          right = [
            {
              id = "SystemMonitor";
            }
            {
              id = "ScreenRecorder";
            }
            {
              id = "Tray";
            }
            {
              id = "NotificationHistory";
            }
            {
              id = "Battery";
            }
            {
              id = "Volume";
            }
            {
              id = "Brightness";
            }
            {
              id = "Clock";
              formatHorizontal = "HH:mm";
              formatVertical = "HH mm";
              useMonospacedFont = true;
              usePrimaryColor = true;
            }
            {
              id = "ControlCenter";
            }
          ];
        };
      };

      # General appearance settings
      general = {
        avatarImage = "${config.home.homeDirectory}/.face";
        radiusRatio = 0.2;
        showScreenCorners = false;
        enableShadows = true;
        animationSpeed = 1;
        lockOnSuspend = true;
      };

      # Color scheme - using default Noctalia colors
      colorSchemes = {
        predefinedScheme = "Noctalia (default)";
        darkMode = true;
      };

      # Location settings for weather/clock
      location = {
        name = "New York";
        weatherEnabled = true;
        use12hourFormat = false;
      };
    };

    # Optional: Enable systemd service through home manager
    # (Only enable one - either here or in system module)
    # systemd.enable = true;
  };
}
