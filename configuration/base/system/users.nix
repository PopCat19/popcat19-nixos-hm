# users.nix
#
# Purpose: Configure user accounts and tmpfiles
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
  systemd.tmpfiles.rules = [
    "d ${userConfig.directories.home}       0755 ${userConfig.username} users -"
    "d ${userConfig.directories.videos}     0755 ${userConfig.username} users -"
    "d ${userConfig.directories.music}      0755 ${userConfig.username} users -"
  ];

  users.users.${userConfig.username} = {
    inherit (userConfig.user) extraGroups;
    isNormalUser = true;
    shell = pkgs.fish;
  };
}
