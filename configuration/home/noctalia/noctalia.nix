# noctalia.nix
#
# Purpose: Main module for Noctalia configuration
#
# This module:
# - Imports Noctalia home manager module
# - Applies user's personalized settings
# - Configures systemd service for autostart
{
  pkgs,
  config,
  inputs,
  userConfig,
  ...
}:
let
  hostname = config.networking.hostName or userConfig.hostname;
  inherit ((import ./settings.nix { inherit pkgs config hostname; })) settings;
in
{
  imports = [
    inputs.noctalia.homeModules.default
  ];

  programs.noctalia-shell = {
    enable = true;
    systemd.enable = false;
    inherit settings;
  };

  systemd.user.services.noctalia-shell = {
    Unit = {
      Description = "Noctalia Shell (with delay)";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };

    Service = {
      ExecStart = "${pkgs.noctalia-shell}/bin/noctalia-shell";
      ExecStartPre = "${pkgs.coreutils}/bin/sleep 10";
      Restart = "on-failure";
      RestartSec = "5s";
      Type = "simple";
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
