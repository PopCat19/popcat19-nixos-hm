# kanata.nix
#
# Purpose: Run kanata as a user systemd service with hjkl mouse-emulation layer
#
# This module:
# - Installs the kanata-with-cmd package (needed for notify-send toggle alerts)
# - Copies the layered config from ./kanata.kbd to ~/.config/kanata/kanata.kbd
# - Runs kanata via a user systemd service that follows the graphical session
# - Validates the config at Nix build time so syntax errors fail the rebuild
#   before they can fail the service at runtime
#
# System-side dependency: services.kanataUdev.enable must be set so the
# kanata process can open /dev/uinput.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.kanata;

  # Validate the layered kbd config at build time, then expose the
  # validated file as a derivation. Source passes through directly so
  # kanata-with-cmd reads the canonical path; only --check wraps it.
  kanataConfigChecked =
    pkgs.runCommand "kanata-validated.kbd"
      {
        nativeBuildInputs = [ pkgs.kanata-with-cmd ];
      }
      ''
        mkdir -p $out
        cp ${./kanata.kbd} $out/kanata.kbd
        ${lib.getExe pkgs.kanata-with-cmd} --cfg $out/kanata.kbd --check
      '';
in
{
  options.programs.kanata = {
    enable = lib.mkEnableOption "kanata hjkl mouse-emulation layer (requires services.kanataUdev.enable)";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.kanata-with-cmd
      pkgs.libnotify
    ];

    home.file.".config/kanata/kanata.kbd".source = "${kanataConfigChecked}/kanata.kbd";

    systemd.user.services.kanata = {
      Unit = {
        Description = "kanata hjkl mouse-emulation remapper";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
        Documentation = "https://github.com/jtroo/kanata";
      };
      Service = {
        ExecStart = "${lib.getExe pkgs.kanata-with-cmd} --cfg %h/.config/kanata/kanata.kbd";
        # ExecReload sends SIGTERM which triggers the Restart=always below.
        # Kanata does not live-reload on SIGUSR1 (only on the lrld action
        # via TCP), so we do a full restart when the kbd file changes.
        ExecReload = "${pkgs.coreutils}/bin/kill -TERM $MAINPID";
        Restart = "always";
        RestartSec = "5s";
        # XDG_RUNTIME_DIR and DBUS_SESSION_BUS_ADDRESS are inherited from the
        # user session so notify-send reaches the notification daemon.
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };

    # Ensure the kanata service restarts after every home-manager activation
    # so config changes from rebuilds always take effect. The reloadTriggers=
    # property on the service didn't wire up a path unit when tested, and
    # the systemd.user.paths schema is fiddly.
    #
    # entryAfter "linkGeneration" (NOT "writeBoundary") is critical:
    # writeBoundary only runs preflight checks; the actual file
    # symlinks at ~/.config/kanata/kanata.kbd are placed later by
    # linkGeneration. Depending on writeBoundary makes the restart
    # race linkGeneration by ~1s — kanata starts, reads the OLD
    # symlink, loads OLD config into memory, then linkGeneration
    # swaps the symlink to the NEW store path and kanata never
    # notices. Symptom: notify-send fires (the script ran),
    # try-restart succeeds (new PID), but the running config is
    # still stale until the next manual restart.
    #
    # Two failure modes are handled inside the script:
    # 1. XDG_RUNTIME_DIR may be unset in the activation environment even
    #    though the user bus exists at /run/user/<uid>/bus. Reconstruct
    #    it from `stat -c %u "$HOME"` (the home dir's owner uid, which is
    #    the real user uid even when sudo runs the activation as root).
    #    Also default DBUS_SESSION_BUS_ADDRESS to the matching socket so
    #    notify-send (called by the kanata kbd via cmd-action) can reach
    #    the notification daemon after a restart.
    # 2. Activation runs through `sudo` may have a stripped PATH that does
    #    not include systemctl or stat, so reference them by absolute path.
    # A failure to restart is logged but never fatal — the service will
    # pick up the new kbd symlink on its next start.
    #
    # On success, fire a desktop notification via notify-send so the user
    # gets visible confirmation that the reload actually fired (without it,
    # the only signal is a journal entry, which is easy to miss during a
    # rebuild). notify-send failures are swallowed (`|| true`) so a broken
    # notification daemon does not abort the activation.
    home.activation.kanataRestart = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      if [ -L "$HOME/.config/kanata/kanata.kbd" ]; then
        uid="$(${pkgs.coreutils}/bin/stat -c %u "$HOME")"
        runtime_dir="''${XDG_RUNTIME_DIR:-/run/user/$uid}"

        export XDG_RUNTIME_DIR="$runtime_dir"
        export DBUS_SESSION_BUS_ADDRESS="''${DBUS_SESSION_BUS_ADDRESS:-unix:path=$runtime_dir/bus}"

        if [ -S "$runtime_dir/bus" ] && ${pkgs.systemd}/bin/systemctl --user status >/dev/null 2>&1; then
          echo "kanata: restarting user service..."
          if ${pkgs.systemd}/bin/systemctl --user try-restart kanata.service; then
            ${lib.getExe pkgs.libnotify} "kanata" "reloaded after rebuild" -t 2000 -u low || true
            echo "kanata: restart complete"
          else
            echo "kanata: restart failed (will pick up on next start)"
          fi
        else
          echo "kanata: user systemd session not reachable (uid=$uid); skipping restart"
        fi
      fi
    '';
  };
}
