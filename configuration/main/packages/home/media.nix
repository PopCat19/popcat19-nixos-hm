# Media packages
{pkgs, ...}:
with pkgs; [
  mpv
  audacious
  audacious-plugins
  pureref
  youtube-music
  mangayomi
  kdePackages.gwenview

  # Streaming and Gaming
  # obs-studio moved to home_modules/obs.nix
]
