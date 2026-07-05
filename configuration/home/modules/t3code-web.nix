# t3code-web.nix
#
# Purpose: Run T3 Code in web/server mode as a systemd user service, exposing
# the full browser UI on localhost without launching the Electron shell.
#
# This module:
# - Wraps the bundled Node server entry point (bin.mjs) from the t3code-flake
#   package with a stable script
# - Runs it as a systemd user service on 127.0.0.1:9098 in web mode
# - Prints the pairing URL to the journal on each start (token rotates per
#   run; read it with `journalctl --user -u t3code-web`)
#
# Why not the Electron binary: the desktop app launches its own Chromium
# window and does not expose a headless web-mode flag. The same underlying
# server is bundled at resources/app.asar.unpacked/apps/server/dist/bin.mjs
# and runs standalone with node. See T3 Code "Server Options" docs.
#
# Path fragility: bin.mjs is an internal bundled path, not a public package
# output. If t3code-flake restructures its AppImage, this breaks. The path
# is asserted at eval time below so failures surface as Nix eval errors
# rather than runtime ExecStart failures.
#
# Auth: loopback + rotating pairing token (per the user's choice). Each
# restart prints a new pair URL to the journal. For zrok/Tailscale exposure
# later, switch to a fixed --auth-token stored in agenix; the pairing flow
# does not survive remote access because the token changes every run.
#
# Zrok: to expose via zrok like odysseus/searxng, add a sibling
# configuration/services/zrok/t3code.nix mirroring odysseus.nix with a
# reserved share whose target endpoint is http://127.0.0.1:9098. That lives
# in the system zrok set, not here.
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.services.t3code-web;
  inherit (pkgs.stdenv.hostPlatform) system;

  t3-code = inputs.t3code-flake.packages.${system}.t3-code;
  serverMjs = "${t3-code}/libexec/t3-code/resources/app.asar.unpacked/apps/server/dist/bin.mjs";

  # Assert the internal path exists at eval time so a restructure fails
  # loudly here, not at service start.
  assertPath = builtins.pathExists serverMjs;

  runner = pkgs.writeShellScriptBin "t3code-web-runner" ''
    set -Eeuo pipefail

    # Line-buffer node's output so the pairing URL reaches the
    # clipboard filter without waiting on a full pipe buffer.
    ${lib.getBin pkgs.coreutils}/bin/stdbuf -oL \
      ${lib.getExe pkgs.nodejs} ${serverMjs} start \
        --mode web \
        --port ${toString cfg.port} \
        --host ${cfg.host} \
        --no-browser 2>&1 |
      while IFS= read -r line; do
        echo "$line"
        case "$line" in
          *"pairingUrl:"*)
            url="''${line##*pairingUrl: }"
            url="''${url%%[[:space:]]*}"
            if command -v ${lib.getExe' pkgs.wl-clipboard "wl-copy"} >/dev/null 2>&1; then
              printf '%s' "$url" | ${lib.getExe' pkgs.wl-clipboard "wl-copy"} 2>/dev/null || true
            fi
            if command -v ${lib.getExe pkgs.libnotify} >/dev/null 2>&1; then
              ${lib.getExe pkgs.libnotify} "T3 Code" "Pairing URL copied to clipboard" -t 2000 -u low 2>/dev/null || true
            fi
            ;;
        esac
      done
  '';
in
{
  options.services.t3code-web = {
    enable = lib.mkEnableOption "T3 Code web server (browser UI, no Electron)";

    port = lib.mkOption {
      type = lib.types.port;
      default = 9098;
      description = "Localhost port for the T3 Code web UI.";
    };

    host = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = ''
        Host/interface to bind. Keep 127.0.0.1 for loopback-only.
        Set to 0.0.0.0 only with a fixed auth token (not the pairing flow).
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = assertPath;
        message = ''
          t3code-web: bundled server entry point not found at ${serverMjs}.
          The t3code-flake package structure likely changed; update the path
          in configuration/home/modules/t3code-web.nix.
        '';
      }
    ];

    home.packages = [ runner ];

    systemd.user.services.t3code-web = {
      Unit = {
        Description = "T3 Code web server (browser UI on localhost:${toString cfg.port})";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = lib.getExe runner;
        Restart = "on-failure";
        RestartSec = "5";
        # node needs HOME for ~/.t3/userdata state + sqlite.
        # WAYLAND_DISPLAY + XDG_RUNTIME_DIR so wl-copy can reach the
        # compositor to place the pairing URL on the clipboard.
        Environment = [
          "HOME=%h"
          "WAYLAND_DISPLAY=wayland-1"
          "XDG_RUNTIME_DIR=/run/user/%U"
        ];
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
