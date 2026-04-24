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
    ]
    ++ x86_64Packages
    ++ [
      inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.opencode
      inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.pi
    ];
}
