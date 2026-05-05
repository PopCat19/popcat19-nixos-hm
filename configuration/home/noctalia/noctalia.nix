# noctalia.nix
#
# Purpose: Main module for Noctalia configuration
#
# This module:
# - Uses programs.noctalia-shell for proper Stylix integration
# - Applies user's personalized settings
# - Configures systemd service for autostart with delay
{
  pkgs,
  config,
  inputs,
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
  imports = [ inputs.noctalia-shell.homeModules.default ];

  programs.noctalia-shell = {
    enable = true;
    package = pkgs.noctalia-shell;

    # Settings from settings.nix - Stylix will set colors separately
    inherit (settings) settings;
  };

  # Custom systemd service with startup delay (not using deprecated .systemd.enable)
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
