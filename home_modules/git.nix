{userConfig, ...}: {
  programs.git = {
    enable = true;
    userName = userConfig.git.userName;
    userEmail = userConfig.git.userEmail;
    extraConfig = userConfig.git.extraConfig;
  };
}
