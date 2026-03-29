# packages.nix
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
  x86_64Packages = pkgs.lib.optionals pkgs.stdenv.isx86_64 [
    pkgs.freerdp
    pkgs.rocmPackages.rpp
  ];
in
{
  environment.systemPackages =
    with pkgs;
    [
      # Desktop
      fuzzel
      kdePackages.qtstyleplugin-kvantum

      # Development
      gh
      python313Packages.pip
      unzip

      # Files
      e2fsprogs
      eza

      # Graphics
      drawpile
      kdePackages.filelight

      # Hardware
      brightnessctl
      ddcutil
      i2c-tools
      usbutils
      util-linux

      # Network
      wireguard-tools

      # Productivity
      anki
    ]
    ++ x86_64Packages
    ++ [
      inputs.llm-agents.packages.${pkgs.system}.kilocode-cli
      inputs.llm-agents.packages.${pkgs.system}.opencode
      inputs.llm-agents.packages.${pkgs.system}.pi
    ];
}
