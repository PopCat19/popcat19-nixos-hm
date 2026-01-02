# Media packages
{pkgs, ...}:
with pkgs; [
  mpv
  audacious
  audacious-plugins
  pureref
  pear-desktop
  mangayomi
  kdePackages.gwenview

  # Audio Applications
  audacity
  furnace

  # Torrent
  qbittorrent

  # Streaming and Gaming
  # obs-studio moved to home_modules/obs.nix
]
