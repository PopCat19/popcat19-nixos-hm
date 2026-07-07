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
{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.services.searxng-local;

  # Template with placeholder; secret injected at runtime via preStart
  settingsYmlTemplate = pkgs.writeText "searxng-settings-template.yml" ''
    use_default_settings: true
    server:
      secret_key: "__SECRET_KEY_PLACEHOLDER__"
      bind_address: "0.0.0.0"
      port: 8080
      limiter: false
    search:
      safe_search: 0
      formats:
        - html
        - json
  '';

in
{
  options.services.searxng-local = with lib; {
    enable = mkEnableOption "SearXNG local instance for pi-discord news injection";
    port = mkOption {
      type = types.port;
      default = 9088;
      description = "Host port to bind SearXNG to (localhost only)";
    };
  };

  config = lib.mkIf cfg.enable {
    # When Mullvad VPN connects/disconnects, the host's /etc/resolv.conf changes.
    # The container inherits DNS config at start time, so we must restart it
    # to pick up the current nameservers.  Without this, a stale nameserver
    # (e.g., 100.64.0.3 from Mullvad, or 192.168.50.1 from the local router)
    # can be unreachable → DNS timeouts > SearXNG's 3s per-engine timeout →
    # all engines appear dead.
    # Generate settings.yml at runtime with secret_key from agenix.
    # Runs before the container starts so the file is ready at mount time.
    systemd.services.searxng-settings = {
      description = "Generate SearXNG settings with agenix secret key";
      before = [ "docker-searxng.service" ];
      wantedBy = [ "docker-searxng.service" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
                TMPL=${settingsYmlTemplate}
                SECRET_PATH=${config.age.secrets.searxng-secret-key.path}
                umask 077
                ${pkgs.python3}/bin/python3 -c "
        import sys
        tmpl_path = '$TMPL'
        secret_path = '$SECRET_PATH'
        tmpl = open(tmpl_path).read()
        secret = open(secret_path).read().strip()
        sys.stdout.write(tmpl.replace('__SECRET_KEY_PLACEHOLDER__', secret))
        " > /run/searxng-settings.yml
      '';
    };

    systemd.paths.searxng-dns-watch = {
      wantedBy = [ "multi-user.target" ];
      pathConfig = {
        PathChanged = "/etc/resolv.conf";
      };
    };
    systemd.services.searxng-dns-watch = {
      description = "Restart SearXNG container when resolv.conf changes (VPN connect/disconnect)";
      after = [ "docker-searxng.service" ];
      wants = [ "docker-searxng.service" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = false;
        # Wrap in a single argv slot so systemd's whitespace-split can't mangle
        # the inline shell command.  Delay to let the DNS proxy settle, then
        # restart the container so it picks up the current nameservers.
        ExecStart =
          let
            script = pkgs.writeShellScript "searxng-restart-on-dns-change" ''
              sleep 2
              ${pkgs.systemd}/bin/systemctl try-restart docker-searxng.service
            '';
          in
          "${script}";
      };
    };

    virtualisation.oci-containers.containers.searxng = {
      image = "searxng/searxng:2026.7.6-556d08c39";
      ports = [ "127.0.0.1:${toString cfg.port}:8080" ];
      volumes = [
        "/run/searxng-settings.yml:/etc/searxng/settings.yml:ro"
      ];
      environment = {
        SEARXNG_BASE_URL = "http://localhost:${toString cfg.port}";
      };
      autoStart = true;
    };
  };
}
