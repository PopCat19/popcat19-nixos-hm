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
  kanataConfigChecked = pkgs.runCommand "kanata-validated.kbd"
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
    home.packages = [ pkgs.kanata-with-cmd ];

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
    # the systemd.user.paths schema is fiddly. entryAfter writeBoundary runs
    # this script after files (including the kbd symlink) have been written.
    #
    # When invoked via sudo nixos-rebuild switch (or nh os switch), the
    # home-manager activation runs as the user but the user systemd session
    # may not be reachable from this context (no $XDG_RUNTIME_DIR or the
    # bus socket isn't mounted). Detect that case and skip the restart
    # rather than failing the whole activation. A failure to restart is
    # logged but never fatal — the service will pick up the new kbd symlink
    # on its next start.
    home.activation.kanataRestart = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ -L "$HOME/.config/kanata/kanata.kbd" ]; then
        if [ -n "$XDG_RUNTIME_DIR" ] && systemctl --user status >/dev/null 2>&1; then
          echo "kanata: restarting user service..."
          systemctl --user try-restart kanata.service \
            || echo "kanata: restart failed (will pick up on next start)"
          echo "kanata: restart complete"
        else
          echo "kanata: user systemd session not reachable; skipping restart"
        fi
      fi
    '';
  };
}
