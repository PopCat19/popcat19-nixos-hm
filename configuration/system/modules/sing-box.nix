# sing-box.nix
#
# Purpose: Togglable sing-box TUN proxy service with fish toggle functions
#
# This module layers TUN-mode configuration and fish toggles on top of the
# nixpkgs `services.sing-box` module. It replaces the old proxy.nix approach
# of setting HTTP_PROXY/HTTPS_PROXY env vars with system-level transparent
# proxying via a TUN interface.
#
# Mullvad compatibility:
# - UDP traffic on WireGuard ports (51820) is routed directly, bypassing the
#   proxy chain, so Mullvad WireGuard packets aren't captured by the TUN.
# - When both sing-box and Mullvad are active, app traffic flows through
#   sing-box (proxy) → Mullvad (VPN) → internet naturally because sing-box's
#   outbound traffic uses the system routing table which includes Mullvad's routes.
#
# Toggle:
# - singbox-on [host] [port] : start the TUN service
# - singbox-off              : stop the TUN service
# - proxify <cmd>            : launch app with explicit SOCKS5 proxy
{
  config,
  lib,
  pkgs,
  userConfig,
  ...
}:
let
  cfg = config.services.sing-box;

  mkFishFunction = path: text: {
    "fish/functions/${path}".text = text;
  };

  # Fish toggle functions
  singboxOnBody = ''
    function singbox_on
        set -l _host (test -n "$argv[1]"; and echo "$argv[1]"; or echo (set -q PROXY_HOST; and echo $PROXY_HOST; or echo "${cfg.proxyHost}"))
        set -l _port (test -n "$argv[2]"; and echo "$argv[2]"; or echo (set -q PROXY_SOCKS_PORT; and echo $PROXY_SOCKS_PORT; or echo "${toString cfg.proxyPort}"))

        if test "$_host" != "${cfg.proxyHost}" -o "$_port" != "${toString cfg.proxyPort}"
            set_color yellow; echo "[INFO] Requested $_host:$_port differs from NixOS default (${cfg.proxyHost}:${toString cfg.proxyPort})"; set_color normal
            set_color yellow; echo "[INFO] Set services.sing-box.proxyHost/Port in your Nix config and rebuild"; set_color normal
        end

        if systemctl is-active --quiet sing-box
            set_color yellow; echo "[INFO] sing-box already running"; set_color normal
            return 0
        end

        echo -n "Starting sing-box TUN... "
        if sudo systemctl start sing-box
            set_color green; echo "[OK]"; set_color normal
            echo "Proxy active: TUN interface routing via $_host:$_port"
        else
            set_color red; echo "[FAIL]"; set_color normal
            echo "Check: sudo systemctl status sing-box"
            return 1
        end
    end
  '';

  singboxOffBody = ''
    function singbox_off
        if not systemctl is-active --quiet sing-box
            set_color yellow; echo "[INFO] sing-box not running"; set_color normal
            return 0
        end

        echo -n "Stopping sing-box TUN... "
        if sudo systemctl stop sing-box
            set_color red; echo "[OK]"; set_color normal
            echo "Proxy disabled"
        else
            set_color red; echo "[FAIL]"; set_color normal
            return 1
        end
    end
  '';

  proxifyBody = ''
    function proxify
        set -l cmd_args

        if test -z "$argv"
            if test -t 0
                echo "Usage: proxify <command> [args...]"
                echo "Launches a command with SOCKS5 proxy configured for Chromium browsers."
                echo "For system-wide proxy, use: singbox_on / singbox_off"
                return 1
            end
            set cmd_args (cat | string split " ")
        else
            set cmd_args $argv
        end

        # If sing-box TUN is active, apps are already proxied: just launch
        if systemctl is-active --quiet sing-box 2>/dev/null
            set_color cyan; echo "[RUN] $cmd_args[1] (via sing-box TUN)"; set_color normal
            if command -q uwsm
                uwsm app -- $cmd_args >/dev/null 2>&1 &
                disown
            else
                $cmd_args >/dev/null 2>&1 &
                disown
            end
            return 0
        end

        # Fallback: explicit SOCKS5 proxy for Chromium-based browsers
        set -l _host (set -q PROXY_HOST; and echo $PROXY_HOST; or echo "${cfg.proxyHost}")
        set -l _proxy_port (set -q PROXY_SOCKS_PORT; and echo $PROXY_SOCKS_PORT; or echo "${toString cfg.proxyPort}")

        set_color cyan; echo "[RUN] $cmd_args[1] (HTTP proxy $_host:$_proxy_port)"; set_color normal

        set -l cmd_name (basename "$cmd_args[1]")
        set -l chromium_apps chrome chromium google-chrome brave edge opera vivaldi electron

        if contains $cmd_name $chromium_apps
            set cmd_args $cmd_args --proxy-server="http://$_host:$_proxy_port"
        end

        if command -q uwsm
            uwsm app -- $cmd_args >/dev/null 2>&1 &
            disown
        else
            $cmd_args >/dev/null 2>&1 &
            disown
        end
    end
  '';

in
{
  options.services.sing-box = {
    proxyHost = lib.mkOption {
      type = lib.types.str;
      default = "192.168.49.1";
      description = "Default SOCKS5 proxy server hostname or IP";
    };
    proxyPort = lib.mkOption {
      type = lib.types.port;
      default = 8282;
      description = "Default HTTP proxy server port (TetherFuseNet)";
    };
    autoStart = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to start sing-box TUN automatically on boot";
    };
    autoTrigger = lib.mkOption {
      type = lib.types.nullOr (
        lib.types.enum [
          "ip"
          "ssid"
        ]
      );
      default = "ip";
      description = ''
        Auto-start/stop sing-box based on network connection.
        - "ip": start when WiFi interface gets a 192.168.49.x address (TetherFuseNet default)
        - "ssid": start when connected to a WiFi Direct SSID (starts with DIRECT-)
        - null: disable auto-trigger
      '';
    };
    mullvadCompat = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Disable Mullvad VPN when sing-box starts (phone already has VPN).
        Re-enables Mullvad auto-connect when sing-box stops (only if autoTrigger is set).
        Requires services.vpn.nix (mullvad-vpn) to be enabled.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    # ── Sing-box TUN configuration ─────────────────────────────────

    services.sing-box.settings = {
      log = {
        level = "info";
      };

      dns = {
        servers = [
          {
            # Local DNS: resolve LAN/private domains, /etc/hosts, system DNS
            type = "local";
            tag = "dns-local";
          }
          {
            # Remote DNS via proxy: prevents DNS leaks (SOCKS5h equivalent)
            type = "https";
            tag = "dns-proxy";
            server = "1.1.1.1";
            detour = "proxy";
            domain_resolver = "dns-local";
          }
        ];
        rules = [
          {
            rule_set = [ "private" ];
            server = "dns-local";
          }
        ];
        final = "dns-proxy";
      };

      inbounds = [
        {
          type = "tun";
          tag = "tun-in";
          interface_name = "singtun";
          address = [ "172.19.0.1/30" ];
          auto_route = true;
          strict_route = false;
          # Exclude proxy server itself from TUN to avoid routing loop
          route_address = [
            "0.0.0.0/0"
          ];
          route_exclude_address = [
            # Only exclude link-local, multicast, and Docker bridge: never proxy these
            # 192.168.0.0/16 intentionally NOT excluded so DNS (192.168.49.1:53)
            # gets captured by TUN hijack; proxy loop prevented by fwmark bypass
            "169.254.0.0/16"
            "224.0.0.0/3"
            "172.17.0.0/16"
            "172.20.0.0/16"
            "fc00::/7"
            "fe80::/10"
          ];
          mtu = 1500;
        }
      ];

      outbounds = [
        {
          type = "direct";
          tag = "direct";
        }
        {
          type = "http";
          tag = "proxy-http";
          server = cfg.proxyHost;
          server_port = cfg.proxyPort;
        }
        {
          type = "socks";
          tag = "proxy-socks";
          server = cfg.proxyHost;
          server_port = cfg.proxyPort;
          version = "5";
        }
        {
          # Auto-pick: tests both, uses first responder (both stay alive concurrently)
          type = "urltest";
          tag = "proxy";
          outbounds = [
            "proxy-http"
            "proxy-socks"
          ];
          url = "http://www.gstatic.com/generate_204";
          interval = "10m";
        }
      ];

      route = {
        auto_detect_interface = true;
        # Required by sing-box 1.12+: specifies DNS server for resolving outbound destinations
        default_domain_resolver = "dns-local";
        rule_set = [
          {
            type = "inline";
            tag = "private";
            rules = [
              {
                ip_cidr = [
                  "10.0.0.0/8"
                  "172.16.0.0/12"
                  "192.168.0.0/16"
                ];
              }
            ];
          }
        ];
        rules = [
          # Sniff protocol on first packet (required for DNS hijack / domain routing)
          {
            inbound = [ "tun-in" ];
            action = "sniff";
          }
          # Hijack DNS to sing-box DNS subsystem
          {
            protocol = "dns";
            action = "hijack-dns";
          }
          # Bypass WireGuard UDP: never send through proxy
          {
            protocol = "udp";
            port = [ 51820 ];
            outbound = "direct";
          }
          {
            rule_set = [ "private" ];
            outbound = "direct";
          }
          {
            inbound = [ "tun-in" ];
            outbound = "proxy";
          }
        ];
        final = "direct";
      };

      experimental = {
        cache_file = {
          enabled = true;
          path = "/var/cache/sing-box/cache.db";
        };
      };
    };

    # ── Systemd TUN overrides ─────────────────────────────────────
    # The nixpkgs module provides the base service; we override for TUN mode.

    systemd.services.sing-box = {
      # Togglable: don't auto-start unless explicitly opted in
      wantedBy = lib.mkIf (!cfg.autoStart) (lib.mkForce [ ]);

      serviceConfig = {
        # TUN device access: /dev/net/tun is world-rw (0666) on NixOS
        PrivateDevices = lib.mkForce false;
      };
    };

    # Cache directory for sing-box
    systemd.tmpfiles.rules = [
      "d /var/cache/sing-box 0755 sing-box sing-box -"
    ];

    # ── Mullvad integration ──────────────────────────────────────
    # When sing-box starts, disable Mullvad (phone already has VPN).
    # When sing-box stops on non-TetherFuseNet, re-enable Mullvad.

    systemd.services.sing-box.preStart = lib.mkIf cfg.mullvadCompat ''
      if command -v ${pkgs.mullvad-vpn}/bin/mullvad >/dev/null && \
         ${pkgs.mullvad-vpn}/bin/mullvad status >/dev/null 2>&1; then
        # Save Mullvad auto-connect state (persistent: survives reboot)
        if ${pkgs.mullvad-vpn}/bin/mullvad auto-connect get | grep -q on; then
          echo on > /var/lib/sing-box/mullvad-state
        else
          echo off > /var/lib/sing-box/mullvad-state
        fi
        ${pkgs.mullvad-vpn}/bin/mullvad auto-connect set off
        ${pkgs.mullvad-vpn}/bin/mullvad disconnect 2>/dev/null || true
      fi
    '';

    systemd.services.sing-box.postStop = lib.mkIf (cfg.mullvadCompat && cfg.autoTrigger != null) ''
      if [ -f /var/lib/sing-box/mullvad-state ] && \
         command -v ${pkgs.mullvad-vpn}/bin/mullvad >/dev/null && \
         ${pkgs.mullvad-vpn}/bin/mullvad status >/dev/null 2>&1; then
        if [ "$(cat /var/lib/sing-box/mullvad-state)" = on ]; then
          ${pkgs.mullvad-vpn}/bin/mullvad auto-connect set on
          ${pkgs.mullvad-vpn}/bin/mullvad connect 2>/dev/null || true
        fi
        rm -f /var/lib/sing-box/mullvad-state
      fi
    '';

    # Recovery: if sing-box crashed/rebooted with Mullvad disabled,
    # restore Mullvad auto-connect on next boot.
    systemd.services.sing-box-mullvad-recover =
      lib.mkIf (cfg.mullvadCompat && cfg.autoTrigger != null)
        {
          description = "Restore Mullvad state after unclean sing-box shutdown";
          after = [ "mullvad-daemon.service" ];
          requires = [ "mullvad-daemon.service" ];
          wantedBy = [ "multi-user.target" ];
          serviceConfig.Type = "oneshot";
          script = ''
            if [ -f /var/lib/sing-box/mullvad-state ] && \
               command -v ${pkgs.mullvad-vpn}/bin/mullvad >/dev/null && \
               ! ${config.systemd.package}/bin/systemctl is-active --quiet sing-box 2>/dev/null; then
              if [ "$(cat /var/lib/sing-box/mullvad-state)" = on ]; then
                ${pkgs.mullvad-vpn}/bin/mullvad auto-connect set on
                ${pkgs.mullvad-vpn}/bin/mullvad connect 2>/dev/null || true
              fi
              rm -f /var/lib/sing-box/mullvad-state
            fi
          '';
        };

    # ── NetworkManager auto-trigger ──────────────────────────────

    environment.etc =
      mkFishFunction "singbox_on.fish" singboxOnBody
      // mkFishFunction "singbox_off.fish" singboxOffBody
      // mkFishFunction "proxify.fish" proxifyBody
      // (
        let
          triggerScript = pkgs.writeShellScript "nm-singbox-trigger" ''
            set -euo pipefail
            IFACE="$1"
            ACTION="$2"

            [ -d "/sys/class/net/$IFACE/wireless" ] || exit 0

            if [ "$ACTION" = "up" ]; then
            ${
              if cfg.autoTrigger == "ip" then
                ''
                  _restart_singbox() {
                    if ${config.systemd.package}/bin/systemctl is-active --quiet sing-box 2>/dev/null; then
                      ${config.systemd.package}/bin/systemctl try-restart sing-box 2>/dev/null || true
                    else
                      ${config.systemd.package}/bin/systemctl start sing-box 2>/dev/null || true
                    fi
                  }
                  if ip -4 addr show "$IFACE" | grep -q 'inet 192\.168\.49\.'; then
                    _restart_singbox
                  fi
                ''
              else
                ''
                  _restart_singbox() {
                    if ${config.systemd.package}/bin/systemctl is-active --quiet sing-box 2>/dev/null; then
                      ${config.systemd.package}/bin/systemctl try-restart sing-box 2>/dev/null || true
                    else
                      ${config.systemd.package}/bin/systemctl start sing-box 2>/dev/null || true
                    fi
                  }
                  SSID="$(${pkgs.iw}/bin/iwgetid -r "$IFACE" 2>/dev/null || true)"
                  case "$SSID" in
                    DIRECT-*) _restart_singbox ;;
                  esac
                ''
            }
            elif [ "$ACTION" = "down" ]; then
              FOUND=0
              for i in /sys/class/net/*/wireless; do
                IF="$(basename "$(dirname "$i")")"
                [ "$IF" = "$IFACE" ] && continue
            ${
              if cfg.autoTrigger == "ip" then
                ''
                  if ip -4 addr show "$IF" 2>/dev/null | grep -q 'inet 192\.168\.49\.'; then
                    FOUND=1; break
                  fi
                ''
              else
                ''
                  S="$(${pkgs.iw}/bin/iwgetid -r "$IF" 2>/dev/null || true)"
                  case "$S" in DIRECT-*) FOUND=1; break ;; esac
                ''
            }
              done
              [ "$FOUND" = 0 ] && ${config.systemd.package}/bin/systemctl stop sing-box 2>/dev/null || true
            fi
          '';
        in
        lib.optionalAttrs (cfg.autoTrigger != null) {
          "NetworkManager/dispatcher.d/90-singbox" = {
            source = triggerScript;
            mode = "0755";
          };
        }
      );

    # ── Firewall ──────────────────────────────────────────────────

    networking.firewall.trustedInterfaces = [ "singtun" ];

    # ── Sudo rules ────────────────────────────────────────────────
    # Passwordless systemctl for sing-box toggling

    security.sudo.extraRules = lib.optionals (userConfig ? username) [
      {
        users = [ userConfig.username ];
        commands = [
          {
            command = "/run/current-system/sw/bin/systemctl start sing-box";
            options = [ "NOPASSWD" ];
          }
          {
            command = "/run/current-system/sw/bin/systemctl stop sing-box";
            options = [ "NOPASSWD" ];
          }
          {
            command = "/run/current-system/sw/bin/systemctl restart sing-box";
            options = [ "NOPASSWD" ];
          }

        ];
      }
    ];
  };
}
