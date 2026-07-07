# users.nix
#
# Purpose: Configure user accounts, tmpfiles, and sudo rules
#
# This module:
# - Creates the main user account with shell and groups
# - Configures tmpfiles rules for the user's home directories
# - Grants passwordless sudo for common NixOS/automation commands
# - Allows wheel group full sudo access (requires password)
{
  pkgs,
  config,
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
    isNormalUser = true;
    inherit (userConfig.user) extraGroups;
    hashedPasswordFile = config.age.secrets.user-password-hash.path;
    shell = pkgs.fish;
  };

  security.sudo.extraRules = [
    {
      users = [ userConfig.username ];
      commands = [
        {
          command = "/run/current-system/sw/bin/nixos-rebuild";
          options = [
            "NOPASSWD"
            "SETENV"
          ];
        }
        {
          command = "/run/current-system/sw/bin/systemctl set-environment *";
          options = [
            "NOPASSWD"
            "SETENV"
          ];
        }
        {
          command = "/run/current-system/sw/bin/systemctl unset-environment *";
          options = [
            "NOPASSWD"
            "SETENV"
          ];
        }
        {
          command = "/run/current-system/sw/bin/systemctl restart nix-daemon";
          options = [ "NOPASSWD" ];
        }
        {
          command = "/run/current-system/sw/bin/nix-env";
          options = [
            "NOPASSWD"
            "SETENV"
          ];
        }
        {
          command = "/run/current-system/sw/bin/systemd-run";
          options = [
            "NOPASSWD"
            "SETENV"
          ];
        }
      ];
    }
    {
      groups = [ "wheel" ];
      commands = [
        {
          command = "ALL";
          options = [ "SETENV" ];
        }
      ];
    }
    {
      users = [ userConfig.username ];
      commands = [
        {
          command = "/run/current-system/sw/bin/nh";
          options = [
            "SETENV"
            "NOPASSWD"
          ];
        }
      ];
    }
  ];
}
