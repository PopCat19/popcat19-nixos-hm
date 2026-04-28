# searxng.nix
#
# Purpose: Declare SearXNG metasearch engine via OCI container
#
# Used by: pi-discord orchestrator world-news injection
#
# This module:
# - Declares the searxng/searxng Docker container
# - Generates settings.yml declaratively
# - Binds to localhost:9088 only (not exposed externally)
{ pkgs, config, lib, ... }:
let
  cfg = config.services.searxng-local;

  settingsYml = pkgs.writeText "searxng-settings.yml" ''
    use_default_settings: true
    server:
      secret_key: "pi-discord-orchestrator"
      bind_address: "0.0.0.0"
      port: 8080
      limiter: false
    search:
      safe_search: 0
      formats:
        - html
        - json
  '';

in {
  options.services.searxng-local = with lib; {
    enable = mkEnableOption "SearXNG local instance for pi-discord news injection";
    port = mkOption {
      type = types.port;
      default = 9088;
      description = "Host port to bind SearXNG to (localhost only)";
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation.oci-containers.containers.searxng = {
      image = "searxng/searxng:latest";
      ports = [ "127.0.0.1:${toString cfg.port}:8080" ];
      volumes = [
        "${settingsYml}:/etc/searxng/settings.yml:ro"
      ];
      environment = {
        SEARXNG_BASE_URL = "http://localhost:${toString cfg.port}";
      };
      autoStart = true;
    };
  };
}
