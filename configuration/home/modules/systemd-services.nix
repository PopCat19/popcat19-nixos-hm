# systemd-services.nix
#
# Purpose: Configure custom systemd user services
#
# This module:
# - Initializes theme settings on graphical session start
# - Cleans stale WirePlumber Bluetooth defaults before PipeWire starts
# - Restarts EasyEffects after PipeWire reloads (nixos-rebuild)
{ pkgs, ... }:
{
  systemd.user.services.theme-init = {
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.bash}/bin/bash -c 'sleep 2 && ${pkgs.dconf}/bin/dconf load / < /dev/null'";
      RemainAfterExit = true;
      Type = "oneshot";
    };
    Unit = {
      After = [ "graphical-session-pre.target" ];
      Description = "Initialize theme settings";
      PartOf = [ "graphical-session.target" ];
    };
  };

  # WirePlumber persists default-sink state across boots. Disconnected
  # Bluetooth sinks accumulate and shadow available USB/HDMI sinks, causing
  # silence until manual reroute (wpctl set-default). Wipe state before
  # PipeWire starts so WirePlumber picks the first alive sink.
  systemd.user.services.clean-wp-defaults = {
    Unit = {
      Description = "Clean stale WirePlumber default sink/source state";
      Before = [ "wireplumber.service" ];
      After = [ "pipewire.service" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash -c 'rm -f $HOME/.local/state/wireplumber/default-nodes $HOME/.local/state/wireplumber/default-routes'";
    };
  };

  # EasyEffects orphans its PipeWire node references when pipewire restarts
  # (nixos-rebuild). Restart EE after WirePlumber so DSP chain re-links.
  systemd.user.services.easyeffects-restart = {
    Unit = {
      Description = "Restart EasyEffects after PipeWire reload";
      After = [ "wireplumber.service" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.systemd}/bin/systemctl --user restart easyeffects.service";
    };
  };
