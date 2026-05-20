# firecrawl.nix
#
# Purpose: Declare Firecrawl web scraping API via OCI containers
#
# This module:
# - Runs Firecrawl as 5 OCI containers (api, playwright-service, redis, rabbitmq, nuq-postgres)
# - Exposes the API on a configurable port (default 3002)
# - Creates a dedicated Docker bridge network for inter-container communication
{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.services.firecrawl;
  network = "firecrawl-backend";
in
{
  options.services.firecrawl = with lib; {
    enable = mkEnableOption "Firecrawl web scraping API";
    port = mkOption {
      type = types.port;
      default = 3002;
      description = "Host port to bind the Firecrawl API to";
    };
    environment = mkOption {
      type = types.attrsOf types.str;
      default = { };
      description = "Extra environment variables for the Firecrawl API container";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.docker-create-firecrawl-network = {
      description = "Create the Firecrawl Docker bridge network";
      after = [ "docker.service" ];
      wants = [ "docker.service" ];
      requiredBy = [
        "docker-firecrawl-api.service"
        "docker-firecrawl-playwright-service.service"
        "docker-firecrawl-redis.service"
        "docker-firecrawl-rabbitmq.service"
        "docker-firecrawl-nuq-postgres.service"
      ];
      before = [
        "docker-firecrawl-api.service"
        "docker-firecrawl-playwright-service.service"
        "docker-firecrawl-redis.service"
        "docker-firecrawl-rabbitmq.service"
        "docker-firecrawl-nuq-postgres.service"
      ];
      serviceConfig.Type = "oneshot";
      script = ''
        ${pkgs.docker}/bin/docker network inspect ${network} >/dev/null 2>&1 || \
        ${pkgs.docker}/bin/docker network create ${network}
      '';
    };

    virtualisation.oci-containers.containers = {
      firecrawl-redis = {
        image = "redis:alpine";
        cmd = [
          "redis-server"
          "--bind"
          "0.0.0.0"
        ];
        autoStart = true;
        extraOptions = [
          "--network"
          network
        ];
      };

      firecrawl-rabbitmq = {
        image = "rabbitmq:3-management";
        cmd = [ "rabbitmq-server" ];
        autoStart = true;
        extraOptions = [
          "--network"
          network
        ];
      };

      firecrawl-nuq-postgres = {
        image = "ghcr.io/firecrawl/nuq-postgres:latest";
        environment = {
          POSTGRES_USER = "postgres";
          POSTGRES_PASSWORD = "postgres";
          POSTGRES_DB = "postgres";
        };
        cmd = [
          "postgres"
          "-c"
          "cron.log_run=off"
          "-c"
          "cron.log_statement=off"
        ];
        autoStart = true;
        extraOptions = [
          "--network"
          network
        ];
      };

      firecrawl-playwright-service = {
        image = "ghcr.io/firecrawl/playwright-service:latest";
        environment = {
          PORT = "3000";
        };
        autoStart = true;
        extraOptions = [
          "--network"
          network
        ];
      };

      firecrawl-api = {
        image = "ghcr.io/firecrawl/firecrawl:latest";
        ports = [ "127.0.0.1:${toString cfg.port}:3002" ];
        environment = {
          HOST = "0.0.0.0";
          PORT = "3002";
          REDIS_URL = "redis://firecrawl-redis:6379";
          REDIS_RATE_LIMIT_URL = "redis://firecrawl-redis:6379";
          PLAYWRIGHT_MICROSERVICE_URL = "http://firecrawl-playwright-service:3000/scrape";
          POSTGRES_USER = "postgres";
          POSTGRES_PASSWORD = "postgres";
          POSTGRES_DB = "postgres";
          POSTGRES_HOST = "firecrawl-nuq-postgres";
          POSTGRES_PORT = "5432";
          NUQ_RABBITMQ_URL = "amqp://firecrawl-rabbitmq:5672";
          ENV = "local";
          USE_DB_AUTHENTICATION = "false";
          BULL_AUTH_KEY = "CHANGEME";
          TEST_API_KEY = "fc-owui-key";
          SEARXNG_ENDPOINT = "http://host.docker.internal:9088";
        }
        // cfg.environment;
        dependsOn = [
          "firecrawl-redis"
          "firecrawl-rabbitmq"
          "firecrawl-nuq-postgres"
          "firecrawl-playwright-service"
        ];
        extraOptions = [
          "--network"
          network
          "--add-host"
          "host.docker.internal:host-gateway"
        ];
        autoStart = true;
      };
    };
  };
}
