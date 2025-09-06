# Privacy and security tools configuration

{ pkgs, config, lib, userConfig, ... }:

let
  passwordsDir = "${userConfig.directories.home}/Passwords";
  keepassDb = "${passwordsDir}/keepass.kdbx";

  # Wrapper to open KeePassXC with the synced DB if it exists, else normal launch
  kpxcWrapper = pkgs.writeShellScriptBin "kpxc" ''
    set -e
    DB="${keepassDb}"
    if [ -f "$DB" ]; then
      exec ${pkgs.keepassxc}/bin/keepassxc "$DB" "$@"
    else
      exec ${pkgs.keepassxc}/bin/keepassxc "$@"
    fi
  '';
in
{
  # Packages
  home.packages = with pkgs; [
    keepassxc
    kpxcWrapper
  ];

  # Ensure passwords directory exists (Syncthing also ensures this; harmless if duplicate)
  home.activation.createPasswordsDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p ${passwordsDir}
  '';


  # Autostart KeePassXC (via wrapper) after login on Hyprland sessions so Secret Service is ready.
  # Start minimized to stay silent in background, avoiding duplicate Hyprland exec-once.
  systemd.user.services."kpxc-autostart" = {
    Unit = {
      Description = "Auto-start KeePassXC with synced DB if present (minimized)";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${kpxcWrapper}/bin/kpxc --minimize";
      Restart = "on-failure";
      RestartSec = 2;
      # Ensure DBus is available in the user session (it is under Hyprland with system dbus)
      Environment = [
        "XDG_RUNTIME_DIR=%t"
      ];
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}