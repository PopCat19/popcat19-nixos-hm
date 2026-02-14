# system_packages.nix
#
# Purpose: Consolidated system-level package list
#
# This module:
# - Provides all system-level packages
# - Includes x86_64-specific packages when applicable
{
  pkgs,
  inputs,
  ...
}:
let
  x86_64Packages = if pkgs.stdenv.isx86_64 then [
    pkgs.freerdp
    pkgs.rocmPackages.rpp
  ] else [];
in
{
  environment.systemPackages = with pkgs; [
    # Development
    gh
    python313Packages.pip
    unzip

    # GUI
    anki
    drawpile
    fuzzel
    kdePackages.filelight
    kdePackages.qtstyleplugin-kvantum

    # Hardware
    brightnessctl
    ddcutil
    e2fsprogs
    eza
    i2c-tools
    usbutils
    util-linux

    # Network
    wireguard-tools
  ]
  ++ x86_64Packages
  ++ [ inputs.llm-agents.packages.${pkgs.system}.opencode ];
}
