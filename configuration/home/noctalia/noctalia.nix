# noctalia.nix
#
# Purpose: Main module for Noctalia configuration
#
# This module:
# - Applies user's personalized settings
# - Configures systemd service for autostart
# - Uses nixpkgs noctalia-shell package
{
  pkgs,
  config,
  userConfig,
  ...
}:
let
  hostname = config.networking.hostName or userConfig.hostname;
  enableUWSM = hostname != "popcat19-dedede0";

  settings = import ./settings.nix {
    inherit pkgs config;
    inherit hostname enableUWSM;
  };
in
{
  # Write settings to noctalia config
  xdg.configFile."noctalia/settings.json".source =
    (pkgs.formats.json { }).generate "noctalia-settings"
      settings.settings;

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
