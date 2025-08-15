# Vicinae launcher configuration

{ pkgs, ... }:

{
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
      Restart = "on-failure";
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
}