# audio-control.nix
#
# Purpose: Configure audio control panel and volume management utilities
#
# This module:
# - Provides Pavucontrol audio control panel
# - Enables user-level audio management
{ pkgs, ... }:
{
  home.packages = [ pkgs.pavucontrol ];
}
