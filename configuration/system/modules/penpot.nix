# penpot.nix
#
# Purpose: Declare Penpot design tool via OCI containers
#
# This module:
# - Deploys Penpot frontend, backend, exporter, postgres, and valkey containers
# - Creates a dedicated Docker network for inter-container communication
# - Binds frontend to localhost:8080 in reserved self-host port range
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.penpot;
  networkName = "penpot-net";
in
{
  options.services.penpot = with lib; {
    enable = mkEnableOption "Penpot design tool";
    port = mkOption {
      type = types.port;
      default = 8080;
      description = "Host port to bind Penpot frontend to (localhost only)";
    };
    publicUri = mkOption {
      type = types.str;
      default = "http://localhost:${toString cfg.port}";
      description = "Public URI where Penpot is accessible";
    };
    secretKey = mkOption {
      type = types.str;
      default = "change-me-to-a-random-string";
      description = "Secret key for JWT token generation";
    };
    enableRegistration = mkOption {
      type = types.bool;
      default = false;
      description = "Allow new user self-registration";
    };
    enableTelemetry = mkOption {
      type = types.bool;
      default = false;
      description = "Enable anonymous telemetry";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d /var/lib/penpot/postgres 0755 root root -"
      "d /var/lib/penpot/assets 0755 root root -"
    ];

    # Create Docker network for Penpot containers
    systemd.services."docker-network-penpot" = {
      description = "Create Penpot Docker network";
      after = [ "docker.service" ];
      requires = [ "docker.service" ];
      partOf = [ "docker.service" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig.Type = "oneshot";
      serviceConfig.RemainAfterExit = true;
      serviceConfig.ExecStop = "${pkgs.docker}/bin/docker network rm -f ${networkName}";

      script = ''
        ${pkgs.docker}/bin/docker network inspect ${networkName} >/dev/null 2>&1 || \
          ${pkgs.docker}/bin/docker network create ${networkName}
      '';
    };

    virtualisation.oci-containers.containers = {
      penpot-postgres = {
        image = "postgres:15";
        autoStart = true;
        extraOptions = [
          "--network=${networkName}"
          "--stop-signal=SIGINT"
        ];
        volumes = [ "/var/lib/penpot/postgres:/var/lib/postgresql/data" ];
        environment = {
          POSTGRES_DB = "penpot";
          POSTGRES_USER = "penpot";
          POSTGRES_PASSWORD = "penpot";
        };
      };

      penpot-valkey = {
        image = "valkey/valkey:7";
        autoStart = true;
        extraOptions = [ "--network=${networkName}" ];
      };

      penpot-backend = {
        image = "penpotapp/backend:latest";
        autoStart = true;
        extraOptions = [ "--network=${networkName}" ];
        volumes = [ "/var/lib/penpot/assets:/opt/data/assets" ];
        dependsOn = [
          "penpot-postgres"
          "penpot-valkey"
        ];
        environment = {
          PENPOT_FLAGS = lib.concatStringsSep " " (
            [ "disable-onboarding" ]
            ++ lib.optional (!cfg.enableRegistration) "disable-registration"
            ++ lib.optional cfg.enableTelemetry "enable-telemetry"
          );
          PENPOT_PUBLIC_URI = cfg.publicUri;
          PENPOT_SECRET_KEY = cfg.secretKey;
          PENPOT_DATABASE_URI = "postgresql://penpot-postgres/penpot";
          PENPOT_DATABASE_USERNAME = "penpot";
          PENPOT_DATABASE_PASSWORD = "penpot";
          PENPOT_REDIS_URI = "redis://penpot-valkey/0";
          PENPOT_TELEMETRY_ENAB = if cfg.enableTelemetry then "true" else "false";
          PENPOT_HTTP_SERVER_MAX_BODY_SIZE = "367001600";
        };
      };

      penpot-exporter = {
        image = "penpotapp/exporter:latest";
        autoStart = true;
        extraOptions = [ "--network=${networkName}" ];
        dependsOn = [ "penpot-backend" ];
        environment = {
          PENPOT_PUBLIC_URI = cfg.publicUri;
          PENPOT_REDIS_URI = "redis://penpot-valkey/0";
        };
      };

      penpot-frontend = {
        image = "penpotapp/frontend:latest";
        autoStart = true;
        extraOptions = [ "--network=${networkName}" ];
        ports = [ "127.0.0.1:${toString cfg.port}:8080" ];
        volumes = [ "/var/lib/penpot/assets:/opt/data/assets" ];
        dependsOn = [
          "penpot-backend"
          "penpot-exporter"
        ];
        environment = {
          PENPOT_FLAGS = lib.concatStringsSep " " (
            [ "disable-onboarding" ] ++ lib.optional (!cfg.enableRegistration) "disable-registration"
          );
          PENPOT_BACKEND_URI = "http://penpot-backend:6060";
          PENPOT_EXPORTER_URI = "http://penpot-exporter:6061";
          PENPOT_HTTP_SERVER_MAX_BODY_SIZE = "367001600";
        };
      };
    };
  };
}
