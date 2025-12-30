# Perplexica AI-Powered Search Module
#
# Purpose: Deploy and configure Perplexica privacy-focused AI search engine
# Dependencies: docker, searxng | None
# Related: searxng.nix, networking.nix, services.nix
#
# This module:
# - Deploys Perplexica via Docker container
# - Configures persistent volumes for data and uploads
# - Integrates with existing SearXNG backend
# - Sets up networking on port 3000
# - Manages container lifecycle via systemd
{ config, lib, pkgs, ... }: let
  cfg = config.services.perplexica;
in {
  options.services.perplexica = {
    enable = lib.mkEnableOption "Perplexica AI-powered search engine";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.docker;
      description = "Docker package to use for container management";
    };

    image = lib.mkOption {
      type = lib.types.str;
      default = "itzcrazykns1337/perplexica:latest";
      description = "Perplexica Docker image to use";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 3000;
      description = "Port to expose Perplexica on";
    };

    dataVolume = lib.mkOption {
      type = lib.types.str;
      default = "perplexica-data";
      description = "Docker volume name for persistent data";
    };

    uploadsVolume = lib.mkOption {
      type = lib.types.str;
      default = "perplexica-uploads";
      description = "Docker volume name for persistent uploads";
    };

    searxngUrl = lib.mkOption {
      type = lib.types.str;
      default = "http://localhost:8080";
      description = "URL of SearXNG backend service";
    };

    containerName = lib.mkOption {
      type = lib.types.str;
      default = "perplexica";
      description = "Name for the Perplexica container";
    };

    publicInstance = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Configure as public instance (open firewall port)";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.docker
    ];

    # Ensure Docker is running
    systemd.services.docker = {
      description = "Docker Application Container Engine";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "notify";
        ExecStart = "${pkgs.docker}/bin/dockerd";
        ExecReload = "${pkgs.systemd}/bin/systemctl kill docker";
        Restart = "on-failure";
        RestartSec = "5";
        KillMode = "mixed";
        TimeoutStopSec = "30";
        LimitNOFILE = "1048576";
        LimitNPROC = "524288";
        LimitCORE = "infinity";
        TasksMax = "infinity";
        OOMScoreAdjust = -500;
      };
      unitConfig = {
        RequiresMountsFor = "/var/lib/docker";
      };
    };

    # Create systemd service for Perplexica container
    systemd.services.perplexica = {
      description = "Perplexica AI-powered search engine";
      after = [ "docker.service" "network.target" ];
      wantedBy = [ "multi-user.target" ];
      requires = [ "docker.service" ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        User = "root";
        Group = "root";
        ExecStart = "${pkgs.docker}/bin/docker run -d \
          --name ${cfg.containerName} \
          --restart unless-stopped \
          -p ${toString cfg.port}:3000 \
          -v ${cfg.dataVolume}:/home/perplexica/data \
          -v ${cfg.uploadsVolume}:/home/perplexica/uploads \
          ${cfg.image}";
        ExecStop = "${pkgs.docker}/bin/docker stop ${cfg.containerName}";
        ExecStopPost = "${pkgs.docker}/bin/docker rm ${cfg.containerName}";
        TimeoutStartSec = "300";
        TimeoutStopSec = "60";
        KillMode = "mixed";
        KillSignal = "SIGTERM";
      };

      # Pre-create volumes
      script = ''
        # Create volumes if they don't exist
        ${pkgs.docker}/bin/docker volume create ${cfg.dataVolume} || true
        ${pkgs.docker}/bin/docker volume create ${cfg.uploadsVolume} || true
      '';

      # Ensure proper cleanup
      postStop = ''
        # Remove container if it exists
        ${pkgs.docker}/bin/docker rm -f ${cfg.containerName} || true
      '';
    };

    # Open firewall port if public instance
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.publicInstance [
      cfg.port
    ];

    # Health check configuration
    systemd.services.perplexica-health = {
      description = "Perplexica Health Check";
      after = [ "perplexica.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        User = "root";
        Group = "root";
        ExecStart = "${pkgs.docker}/bin/docker exec ${cfg.containerName} /bin/sh -c 'curl -f http://localhost:3000 || exit 1'";
        TimeoutStartSec = "60";
        Restart = "on-failure";
        RestartSec = "30";
      };
    };
  };
}