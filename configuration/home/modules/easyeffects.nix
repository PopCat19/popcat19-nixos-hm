# easyeffects.nix
#
# Purpose: Seed EasyEffects headphone EQ tuning across all hosts via a
# copy-if-absent activation script.
#
# This module:
# - Copies equalizerrc (10-band headphone output EQ) into
#   ~/.config/easyeffects/db/ on first activation only
# - Leaves easyeffectsrc (host-specific USB device binding), graphrc, and any
#   per-host DeepFilterNet / input-chain config alone
# - Never overwrites existing files, so in-UI tuning on any host persists
#   across rebuilds. Re-seed by deleting the file and rebuilding.
#
# Portability: the EQ curve is device-agnostic, but EasyEffects only applies
# it when the matching audio device is selected in easyeffectsrc. On hosts
# without the Razer Kraken, the seeded EQ is inert until a device with the
# same ALSA name is connected, or the user re-picks the output.
#
# DeepFilterNet (mic input denoiser) is intentionally not managed here: its
# tuning is per-host and per-mic, and bypass state is workflow-specific.
# Configure it manually on each host in the EasyEffects UI.
{
  config,
  lib,
  ...
}:
let
  cfg = config.services.easyeffects;
in
{
  config = lib.mkIf cfg.enable {
    # Seed tuning files on first activation only. Copies (not symlinks) so
    # EasyEffects can keep writing them at runtime. Existing files are never
    # touched, so host-specific UI edits persist across rebuilds.
    #
    # Runs after writeBoundary so the activation environment is ready; these
    # files are not HM-managed symlinks so linkGeneration order is irrelevant.
    home.activation.easyeffectsTuning = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      ee_dir="$HOME/.config/easyeffects/db"
      mkdir -p "$ee_dir"

      seed() {
        local src="$1" dst="$2"
        if [ ! -e "$dst" ]; then
          cp "$src" "$dst"
          echo "easyeffects-tuning: seeded $dst"
        fi
      }

      seed "${./easyeffects/equalizerrc}" "$ee_dir/equalizerrc"
    '';
  };
}
