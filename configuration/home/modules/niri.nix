# niri.nix
#
# Purpose: Configure Niri scrollable-tiling Wayland compositor
#
# This module:
# - Enables Niri compositor for Home Manager
# - Does NOT manage config - user edits ~/.config/niri/config.kdl directly
# - Intentionally minimal for learning stock behavior
#
# Note: The niri flake's NixOS module handles home-manager integration
# automatically when programs.niri.enable is true at system level.
_: { }
