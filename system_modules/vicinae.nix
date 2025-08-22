# Vicinae launcher configuration

{ pkgs, lib, allowVicinae ? false, ... }:

#
# Vicinae launcher configuration (DEPRECATED)
# - Vicinae is deprecated in this configuration set. By default it is disabled.
# - To re-enable explicitly for a host, set `allowVicinae = true` when importing this module.
#
let
  cfg = if allowVicinae then {
    # Add Vicinae to system packages
    environment.systemPackages = [ pkgs.vicinae ];

    # Enable Vicinae user service
    systemd.user.services.vicinae = {
      description = "Vicinae Launcher Service";
      documentation = [ "https://github.com/vicinaehq/vicinae" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.vicinae}/bin/vicinae server";
        Restart = "always";
        RestartSec = 5;
        # Environment variables to help with NixOS compatibility
        Environment = [
          "QT_PLUGIN_PATH=${pkgs.qt6.qtbase}/${pkgs.qt6.qtbase.qtPluginPrefix}"
          "QML2_IMPORT_PATH=${pkgs.qt6.qtbase}/${pkgs.qt6.qtbase.qtQmlPrefix}"
        ];
      };
      wantedBy = [ "default.target" ];
    };

    # Add a wrapper script for Vicinae client that handles the server check
    environment.etc."profile.d/vicinae.sh".text = ''
      # Vicinae wrapper function
      vicinae() {
        # Check if server is running
        if ! pgrep -f "vicinae server" > /dev/null; then
          # Start server in background
          ${pkgs.vicinae}/bin/vicinae server &
          # Give it a moment to start
          sleep 2
        fi
        # Run the client
        ${pkgs.vicinae}/bin/vicinae "$@"
      }
    '';
  } else {};
in
cfg