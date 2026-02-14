# proxy.nix
#
# Purpose: Auto-configure system proxy based on Android WiFi Direct SSID
#
# This module:
# - Configures DNS nameservers
# - Sets proxy environment variables for user shell sessions
# - Uses NetworkManager dispatcher to inject proxy into systemd environment
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.proxy;

  patternBase = builtins.substring 0 (
    builtins.stringLength cfg.androidWifiDirect.pattern - 1
  ) cfg.androidWifiDirect.pattern;
in
{
  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      (pkgs.writeShellScriptBin "proxy-toggle" ''
        SSID=$(nmcli -t -f active,ssid dev wifi 2>/dev/null | grep '^yes' | cut -d: -f2)
        if [[ "$SSID" == ${cfg.androidWifiDirect.pattern} ]]; then
          export http_proxy="${cfg.urls.http}"
          export https_proxy="${cfg.urls.https}"
          export all_proxy="${cfg.urls.socks}"
          export no_proxy="${cfg.urls.noProxy}"
          export HTTP_PROXY="$http_proxy"
          export HTTPS_PROXY="$https_proxy"
          export ALL_PROXY="$all_proxy"
          export NO_PROXY="$no_proxy"
          echo "Proxy enabled for $SSID"
        else
          unset http_proxy https_proxy all_proxy no_proxy HTTP_PROXY HTTPS_PROXY ALL_PROXY NO_PROXY
          echo "Proxy disabled"
        fi
      '')
    ];

    networking.nameservers = cfg.nameservers;

    networking.networkmanager.dispatcherScripts = [
      {
        source = pkgs.writeText "wifi-direct-proxy-toggle" ''
          #!/bin/sh
          SSID=$(nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d: -f2)

          if echo "$SSID" | grep -q '^${patternBase}'; then
            systemctl set-environment \
              HTTP_PROXY="${cfg.urls.http}" \
              HTTPS_PROXY="${cfg.urls.https}" \
              ALL_PROXY="${cfg.urls.socks}" \
              NO_PROXY="${cfg.urls.noProxy}"

            for user_id in $(loginctl list-users --no-legend | awk '{print $1}'); do
              sudo -u "#$user_id" DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$user_id/bus \
                systemctl --user set-environment \
                  HTTP_PROXY="${cfg.urls.http}" \
                  HTTPS_PROXY="${cfg.urls.https}" \
                  ALL_PROXY="${cfg.urls.socks}" \
                  NO_PROXY="${cfg.urls.noProxy}"
            done

            systemctl restart nix-daemon
            logger "Nix Proxy: Enabled for $SSID and User Sessions"
          else
            systemctl unset-environment HTTP_PROXY HTTPS_PROXY ALL_PROXY NO_PROXY

            for user_id in $(loginctl list-users --no-legend | awk '{print $1}'); do
              sudo -u "#$user_id" DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$user_id/bus \
                systemctl --user unset-environment HTTP_PROXY HTTPS_PROXY ALL_PROXY NO_PROXY
            done

            systemctl restart nix-daemon
            logger "Nix Proxy: Disabled"
          fi
        '';
        type = "basic";
      }
    ];
  };

  options.proxy = {
    androidWifiDirect = {
      pattern = lib.mkOption {
        default = "DIRECT-*";
        description = "SSID pattern to match for Android WiFi Direct";
        type = lib.types.str;
      };
    };

    enable = lib.mkOption {
      default = false;
      description = "Enable auto-configuration of proxy for Android WiFi Direct";
      type = lib.types.bool;
    };

    nameservers = lib.mkOption {
      default = [
        "8.8.8.8"
        "1.1.1.1"
      ];
      description = "DNS nameservers to use";
      type = lib.types.listOf lib.types.str;
    };

    urls = {
      http = lib.mkOption {
        default = "http://192.168.49.1:8282";
        description = "HTTP proxy URL";
        type = lib.types.str;
      };

      https = lib.mkOption {
        default = "http://192.168.49.1:8282";
        description = "HTTPS proxy URL";
        type = lib.types.str;
      };

      socks = lib.mkOption {
        default = "socks5h://192.168.49.1:1080";
        description = "SOCKS5 proxy URL";
        type = lib.types.str;
      };

      noProxy = lib.mkOption {
        default = "localhost,127.0.0.1";
        description = "Comma-separated list of hosts to bypass proxy";
        type = lib.types.str;
      };
    };
  };
}
