# sillytavern.nix
#
# Purpose: Declare SillyTavern AI chat frontend via OCI container
#          with optional zrok sharing for external access
#
# This module:
# - Runs SillyTavern in a Docker container (ghcr.io/sillytavern/sillytavern)
# - Persists config, data, plugins, extensions, and backups
# - Optionally exposes via zrok reserved share
#
# Migration from existing installation:
#   Copy existing data to persist dir:
#     sudo cp -r ~/SillyTavern-Launcher/SillyTavern/config /var/lib/sillytavern/
#     sudo cp -r ~/SillyTavern-Launcher/SillyTavern/data   /var/lib/sillytavern/
#     sudo cp -r ~/SillyTavern-Launcher/SillyTavern/plugins /var/lib/sillytavern/
#     sudo chown -R root:root /var/lib/sillytavern
{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.services.sillytavern;
in
{
  options.services.sillytavern = with lib; {
    enable = mkEnableOption "SillyTavern AI chat frontend";

    port = mkOption {
      type = types.port;
      default = 8000;
      description = "Host port to bind SillyTavern to";
    };

    listenAddress = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "Host address to bind SillyTavern to";
    };

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/sillytavern";
      description = "Directory for persistent SillyTavern data";
    };

    zrok = {
      enable = mkEnableOption "zrok sharing for SillyTavern via reserved token";

      reservedToken = mkOption {
        type = types.str;
        default = "5f5icptoebhm";
        description = "zrok reserved share token for SillyTavern";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0755 root root -"
      "d ${cfg.dataDir}/config 0755 root root -"
      "d ${cfg.dataDir}/data 0755 root root -"
      "d ${cfg.dataDir}/plugins 0755 root root -"
      "d ${cfg.dataDir}/extensions 0755 root root -"
      "d ${cfg.dataDir}/backups 0755 root root -"
    ];

    virtualisation.oci-containers.containers.sillytavern = {
      image = "ghcr.io/sillytavern/sillytavern:latest";
      ports = [ "${cfg.listenAddress}:${toString cfg.port}:8000" ];
      volumes = [
        "${cfg.dataDir}/config:/home/node/app/config"
        "${cfg.dataDir}/data:/home/node/app/data"
        "${cfg.dataDir}/plugins:/home/node/app/plugins"
        "${cfg.dataDir}/extensions:/home/node/app/public/scripts/extensions/third-party"
        "${cfg.dataDir}/backups:/home/node/app/backups"
      ];
      environment = {
        NODE_ENV = "production";
        FORCE_COLOR = "1";
        SILLYTAVERN_HEARTBEATINTERVAL = "30";
      };
      healthcheck = {
        test = [ "CMD" "node" "src/healthcheck.js" ];
        interval = "30s";
        timeout = "10s";
        startPeriod = "20s";
        retries = 3;
      };
      autoStart = true;
    };

    systemd.services.zrok-share-sillytavern = lib.mkIf cfg.zrok.enable {
      description = "Zrok reserved share tunnel for SillyTavern";
      after = [
        "network-online.target"
        "docker-container-sillytavern.service"
      ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        ExecStart = "${pkgs.zrok}/bin/zrok share reserved ${cfg.zrok.reservedToken}";
        Restart = "on-failure";
        RestartSec = "10";
        User = "popcat19";
        Group = "users";
      };
    };
  };
}
