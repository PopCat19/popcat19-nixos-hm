# x86_64-specific system packages
{ pkgs, ... }:
with pkgs;
[
  # AMD GPU acceleration
  rocmPackages.rpp

  # Remote Desktop Protocol client
  freerdp

  # x86_64-specific system packages can be added here
]
