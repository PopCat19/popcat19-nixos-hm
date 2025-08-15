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
    };
    wantedBy = [ "default.target" ];
  };
}