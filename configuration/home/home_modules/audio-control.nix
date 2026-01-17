# Audio Control Module
#
# Purpose: Configure audio control panel and volume management utilities
# Dependencies: pavucontrol | None
# Related: system_modules/audio.nix | None
#
# This module:
# - Provides Pavucontrol audio control panel
# - Enables user-level audio management
# - Supports system audio service integration
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    pavucontrol
  ];
}
