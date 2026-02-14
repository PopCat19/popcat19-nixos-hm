# Users Configuration Module
#
# Purpose: Configure user accounts and tmpfiles
# Dependencies: userConfig (passed via specialArgs)
# Related: configuration/system/configuration.nix
#
# This module:
# - Creates the main user account
# - Sets up user groups
# - Configures tmpfiles rules
{
  pkgs,
  userConfig,
  ...
}:
{
  # Users and tmpfiles configuration

  # User account
  users.users.${userConfig.username} = {
    isNormalUser = true;
    inherit (userConfig.user) extraGroups;
    shell = pkgs.fish;
  };

  # Tmpfiles rules
  systemd.tmpfiles.rules = [
    "d ${userConfig.directories.home}       0755 ${userConfig.username} users -"
    "d ${userConfig.directories.videos}     0755 ${userConfig.username} users -"
    "d ${userConfig.directories.music}      0755 ${userConfig.username} users -"
  ];
}
