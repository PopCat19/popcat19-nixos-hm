# openrgb-leds.nix
#
# Purpose: Write LED color and apply zone sizes at login
#
# This module:
# - Writes fixed orange hex to ~/.config/openrgb/pmd-led-color
# - Runs a oneshot systemd user service to resize JRAINBOW1→48 after login
# - Separates sizing from coloring to avoid MSI Mystic Light protocol glitches
{
  config,
  ...
}:
let
  ledColor = "#FF2200";
in
{
  home.file.".config/openrgb/pmd-led-color".text = ledColor;

  systemd.user.services.openrgb-zone-size = {
    Unit = {
      Description = "Resize OpenRGB JRAINBOW1 to 48 LEDs and apply PMD color";
      After = [ "graphical-session.target" ];
      Wants = [ "openrgb.service" ];
    };

    Service = {
      Type = "oneshot";
      ExecStart = "%h/.local/bin/openrgb-resize";
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  home.file.".local/bin/openrgb-resize" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      set -Eeuo pipefail

      # Wait up to 30s for OpenRGB SDK server
      for i in {1..30}; do
        if openrgb --list-devices &>/dev/null; then
          break
        fi
        sleep 1
      done

      # Resize zones first (no color to avoid protocol glitches)
      openrgb --device MSI --zone 2 --mode static --size 48
      openrgb --device MSI --zone 3 --mode static --size 0

      # Apply device-wide color after sizing
      openrgb --device MSI --mode static --color "$(sed 's/^#//' "$HOME/.config/openrgb/pmd-led-color")" --brightness 100
    '';
  };
}
