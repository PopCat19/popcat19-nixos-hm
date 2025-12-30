# SearXNG Metasearch Engine Module
#
# Purpose: Deploy and configure SearXNG privacy-focused metasearch engine
# Dependencies: python3, uwsgi, nginx | None
# Related: networking.nix, services.nix
#
# This module:
# - Installs SearXNG and dependencies
# - Configures settings.yml with secure defaults
# - Sets up uWSGI application server
# - Provides systemd service for SearXNG
# - Configures Nginx reverse proxy (optional)
{ config, lib, pkgs, ... }: let
  cfg = config.services.searxng;
  settingsFile = pkgs.writeText "settings.yml" (lib.generators.toYAML {} {
    # General settings
    general = {
      instance_name = "SearXNG";
      debug = false;
      contact = "";
      docs_url = "https://docs.searxng.org";
      donation_url = "https://donate.searxng.org";
      preferences = {
        # Allow users to change language
        lang = true;
        # Allow users to change locale
        locale = true;
      };
    };

    # Server configuration
    server = {
      secret_key = cfg.secretKey;
      base_url = cfg.baseUrl;
      port = cfg.port;
      bind_address = cfg.bindAddress;
      limiter = cfg.enableLimiter;
      public_instance = cfg.publicInstance;
      image_proxy = cfg.enableImageProxy;
      method = if cfg.useGET then "GET" else "POST";
      default_http_headers = {
        X-Content-Type-Options = "nosniff";
        X-Download-Options = "noopen";
        X-Robots-Tag = "noindex, nofollow";
        Referrer-Policy = "no-referrer";
      };
    };

    # Search settings
    search = {
      formats = ["html" "json" "csv" "rss"];
      default_lang = "auto";
      autocomplete = cfg.autocompleteBackend;
      autocomplete_min = 4;
    };

    # Outgoing request settings
    outgoing = {
      request_timeout = 30;
      max_request_timeout = 120;
      useragent_suffix = "";
      pool_connections = 100;
      pool_maxsize = 10;
    };

    # Available engines (basic set)
    engines = [
      {
        name = "DuckDuckGo";
        engine = "duckduckgo";
        categories = ["general" "web"];
        shortcut = "ddg";
        disabled = false;
      }
      {
        name = "Google";
        engine = "google";
        categories = ["general" "web"];
        shortcut = "g";
        disabled = false;
      }
      {
        name = "Wikipedia";
        engine = "wikipedia";
        categories = ["general" "wikis"];
        shortcut = "wp";
        disabled = false;
      }
      {
        name = "Bing";
        engine = "bing";
        categories = ["general" "web"];
        shortcut = "b";
        disabled = false;
      }
    ];

    # DOI resolvers
    doi_resolvers = {
      ox = "https://doi.org/";
      doi_redirect = "https://doi.org/";
    };

    # Plugins (basic set)
    plugins = [
      {
        name = "Self Information";
        plugin = "self_info";
        enabled = true;
      }
      {
        name = "Tracker URLs";
        plugin = "tracker_url";
        enabled = true;
      }
    ];

    # UI plugins
    ui = {
      themes_path = "${pkgs.searxng.data}/searxng/themes";
      default_theme = "simple";
      default_locale = "";
      theme_args = {
        base_url = "";
        endpoint = "simple";
        url_prefix = "";
        css_file = "style.css";
        js_file = "searxng.min.js";
      };
    };
  });

  uwsgiConfig = pkgs.writeText "searxng.ini" ''
    [uwsgi]
    module = searx.webapp
    callable = create_app()
    master = true
    processes = ${toString cfg.processes}
    threads = 2
    socket = /run/searxng/searxng.sock
    chmod-socket = 660
    vacuum = true
    die-on-term = true
    env = SEARXNG_SETTINGS_PATH=${settingsFile}
    pythonpath = ${pkgs.searxng}
    wsgi-file = ${pkgs.searxng}/searx/webapp.py
    virtualenv = ${config.system.path}
  '';

in {
  options.services.searxng = {
    enable = lib.mkEnableOption "SearXNG metasearch engine";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.searxng;
      description = "SearXNG package to use";
    };

    secretKey = lib.mkOption {
      type = lib.types.str;
      default = "changeme-$(openssl rand -hex 16)";
      description = "Secret key for session management (auto-generated if not set)";
    };

    baseUrl = lib.mkOption {
      type = lib.types.str;
      default = "http://localhost:8080";
      description = "Base URL for the SearXNG instance";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 8080;
      description = "Port to bind SearXNG to";
    };

    bindAddress = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "Address to bind SearXNG to";
    };

    enableLimiter = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable request limiter for public instances";
    };

    publicInstance = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Configure as public instance";
    };

    enableImageProxy = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable image proxy for privacy";
    };

    useGET = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Use GET instead of POST for requests";
    };

    processes = lib.mkOption {
      type = lib.types.int;
      default = 4;
      description = "Number of uWSGI processes";
    };

    autocompleteBackend = lib.mkOption {
      type = lib.types.str;
      default = "duckduckgo";
      description = "Autocomplete backend to use";
    };

    nginx = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Nginx reverse proxy configuration";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.searxng
      pkgs.uwsgi
    ];

    systemd.services.searxng = {
      description = "SearXNG Metasearch Engine";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "notify";
        User = "searxng";
        Group = "searxng";
        RuntimeDirectory = "searxng";
        RuntimeDirectoryMode = "750";
        ExecStart = "${pkgs.uwsgi}/bin/uwsgi --ini ${uwsgiConfig}";
        ExecReload = "${pkgs.systemd}/bin/systemctl reload-or-restart searxng";
        Restart = "on-failure";
        RestartSec = "10";
        KillMode = "mixed";
        TimeoutStopSec = "30";
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
      };

      preStart = ''
        mkdir -p /run/searxng
        chown searxng:searxng /run/searxng
      '';

      script = ''
        # Ensure settings file is readable
        chmod 644 ${settingsFile}
      '';
    };

    systemd.tmpfiles.rules = [
      "d /run/searxng 0750 searxng searxng -"
    ];

    users.users.searxng = {
      isSystemUser = true;
      group = "searxng";
      home = "/var/lib/searxng";
      createHome = true;
      description = "SearXNG service user";
      shell = pkgs.bash;
    };

    users.groups.searxng = {};

    # Optional Nginx configuration
    services.nginx.virtualHosts."${cfg.bindAddress}:${toString cfg.port}" = lib.mkIf cfg.nginx {
      serverName = cfg.baseUrl;
      root = "${pkgs.searxng}/searxng";
      locations."/" = {
        try_files = "$uri @searxng";
        proxyPass = "http://unix:/run/searxng/searxng.sock";
        proxySetHeader = {
          Host = "$host";
          X-Real-IP = "$remote_addr";
          X-Forwarded-For = "$proxy_add_x_forwarded_for";
          X-Forwarded-Proto = "$scheme";
        };
      };
    };

    # Open firewall port if public instance
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.publicInstance [
      (lib.mkIf (cfg.port != 80 && cfg.port != 443) cfg.port)
      (lib.mkIf (cfg.port == 80) 80)
      (lib.mkIf (cfg.port == 443) 443)
    ];
  };
}