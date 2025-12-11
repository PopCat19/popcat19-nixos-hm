{
  pkgs,
  userConfig,
  ...
}: {
  # Users and tmpfiles configuration

  # User account
  users.users.${userConfig.user.username} = {
    isNormalUser = true;
    extraGroups = userConfig.user.extraGroups;
    shell = pkgs.${userConfig.user.shell};
  };

  # Tmpfiles rules
  systemd.tmpfiles.rules = [
    "d ${userConfig.directories.home}            0755 ${userConfig.user.username} users -"
    "d ${userConfig.directories.videos}     0755 ${userConfig.user.username} users -"
    "d ${userConfig.directories.music}      0755 ${userConfig.user.username} users -"
  ];
}
