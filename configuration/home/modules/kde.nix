# kde.nix
#
# Purpose: Configure KDE applications and utilities
#
# This module:
# - Installs KDE applications (Gwenview)
# - Configures thumbnail support and theming
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    kdePackages.gwenview

    ffmpegthumbnailer
    poppler-utils
    libgsf
    webp-pixbuf-loader
  ];
}
