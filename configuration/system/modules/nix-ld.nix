# nix-ld.nix
#
# Purpose: Run pre-built Linux binaries (e.g., CloakBrowser Chromium) on NixOS
#
# This module:
# - Enables programs.nix-ld for FHS binary interception
# - Provides runtime libraries pre-built Chromium/Firefox binaries expect
#   (glib, gtk3, nss, X11, etc.) so they can run without Nix packaging
{ pkgs, ... }:
{
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      glib
      gtk3
      nss
      nspr
      cups
      libx11
      libxcb
      libxcomposite
      libxdamage
      libxext
      libxfixes
      libxrandr
      alsa-lib
      libgbm
      libdrm
      at-spi2-core
      dbus
      expat
      pango
      cairo
      libxkbcommon
    ];
  };
}
