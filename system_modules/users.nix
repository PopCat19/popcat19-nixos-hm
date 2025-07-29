{ pkgs, userConfig, ... }:

{
  # **USERS & TMPFILES CONFIGURATION**
  # Defines user accounts, groups, and temporary file rules.
  
  # **USER ACCOUNT**
  users.users.${userConfig.user.username} = {
    isNormalUser = true;
    extraGroups = userConfig.user.extraGroups;
    shell = pkgs.${userConfig.user.shell};
  };

  # **TMPFILES RULES**
  systemd.tmpfiles.rules = [
    "d ${userConfig.directories.home}            0755 ${userConfig.user.username} users -"
    "d ${userConfig.directories.videos}     0755 ${userConfig.user.username} users -"
    "d ${userConfig.directories.music}      0755 ${userConfig.user.username} users -"
  ];
}