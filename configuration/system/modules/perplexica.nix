# perplexica.nix
#
# Purpose: Declare Perplexica AI answer engine via OCI container
#
# This module:
# - Declares the itzcrazykns1337/perplexica:slim-latest container
# - Uses host networking to reach local SearXNG instance
# - Persists data to /var/lib/perplexica
{ config, lib, ... }:

let
  cfg = config.services.perplexica;
in
{
  options.services.perplexica = with lib; {
    enable = mkEnableOption "Perplexica AI answer engine";
    searxngUrl = mkOption {
      type = types.str;
      default = "http://localhost:9088";
      description = "URL of the SearXNG instance to use";
    };
    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/perplexica";
      description = "Directory for persistent Perplexica data";
    };
    environment = mkOption {
      type = types.attrsOf types.str;
      default = { };
      description = "Additional environment variables (e.g. OLLAMA_BASE_URL, OPENAI_API_KEY)";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0755 root root -"
    ];

    virtualisation.oci-containers.containers.perplexica = {
      image = "itzcrazykns1337/perplexica:slim-latest";
      extraOptions = [ "--network=host" ];
      environment = {
        SEARXNG_API_URL = cfg.searxngUrl;
      }
      // cfg.environment;
      volumes = [
        "${cfg.dataDir}:/home/perplexica/data"
      ];
      autoStart = true;
    };
  };
}
