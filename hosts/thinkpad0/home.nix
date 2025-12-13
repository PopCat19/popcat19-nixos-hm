# Host-specific home configuration for thinkpad0
{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ../../configuration/home/home.nix
  ];

  # Host-specific monitor configuration
  home.file.".config/hypr/monitors.conf".source = ./hypr_config/monitors.conf;
}
