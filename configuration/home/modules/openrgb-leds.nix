# openrgb-leds.nix
#
# Purpose: Write PMD theme-derived LED color and apply zone sizes at login
#
# This module:
# - Reads config.lib.stylix.colors.withHashtag.base0D (PMD accent+30°)
# - Writes hex color to ~/.config/openrgb/pmd-led-color
# - Runs a oneshot systemd user service to resize JRAINBOW1→48 after login
# - Replaces static .orp profiles with dynamic theme-following color
{ config, ... }:
let
  ledColor = config.lib.stylix.colors.withHashtag.base04;
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

      # Resize JRAINBOW1 to 48, JRAINBOW2 to 0
      openrgb --device MSI --zone 2 --mode static --size 48 --color "$(sed 's/^#//' "$HOME/.config/openrgb/pmd-led-color")"
      openrgb --device MSI --zone 3 --mode static --size 0  --color "$(sed 's/^#//' "$HOME/.config/openrgb/pmd-led-color")"
    '';
  };
}
