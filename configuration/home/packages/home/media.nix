# media.nix
#
# Purpose: Media packages for audio, video, and images
#
# This module:
# - Provides media players and viewers
# - Provides audio production tools
# - Provides torrent client
{ pkgs, ... }:
with pkgs;
[
  audacious
  audacious-plugins
  audacity
  carla
  furnace
  helio-workstation
  kdePackages.gwenview
  lmms
  mangayomi
  mpv
  pear-desktop
  pureref
  qbittorrent
  qtractor
  vital
]
