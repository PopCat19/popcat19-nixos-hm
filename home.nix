# DEPRECATED: This file is no longer used
#
# Each host now has its own home.nix configuration in hosts/<hostname>/home.nix
#
# Host-specific configurations:
# - hosts/nixos0/home.nix    (includes all modules including generative AI)
# - hosts/thinkpad0/home.nix (excludes generative AI and OpenRGB)
# - hosts/surface0/home.nix  (excludes generative AI and OpenRGB)
#
# For new hosts, use hosts/home-minimal.nix as a template
#
# This file is kept for reference only and will be removed in a future update.
{
  pkgs,
  config,
  system,
  lib,
  inputs,
  userConfig,
  ...
}: {
  # This configuration is deprecated - use host-specific home.nix files instead
  home.username = userConfig.user.username;
  home.homeDirectory = userConfig.directories.home;
  home.stateVersion = "24.05";

  # See hosts/<hostname>/home.nix for actual configurations
  imports = [];

  home.packages = [];
}
