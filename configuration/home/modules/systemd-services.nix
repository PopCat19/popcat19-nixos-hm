# systemd-services.nix
#
# Purpose: Configure custom systemd user services
#
# This module:
# - Initializes theme settings on graphical session start
{ pkgs, ... }:
{
  systemd.user.services.theme-init = {
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.bash}/bin/bash -c 'sleep 2 && ${pkgs.dconf}/bin/dconf load / < /dev/null'";
      RemainAfterExit = true;
      Type = "oneshot";
    };
    Unit = {
      After = [ "graphical-session-pre.target" ];
      Description = "Initialize theme settings";
      PartOf = [ "graphical-session.target" ];
    };
  };
}
