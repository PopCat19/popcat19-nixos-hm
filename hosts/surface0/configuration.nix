# NixOS Configuration for surface0
{
  pkgs,
  inputs,
  lib,
  userConfig,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../../base-configuration/configuration.nix
    ../../main-configuration/configuration.nix
    ./system_modules/clear-bdprochot.nix
    ./system_modules/thermal-config.nix
    ./system_modules/boot.nix
    ./system_modules/hardware.nix
  ];

  networking.hostName = "popcat19-surface0";

  # Add hyprshade to system packages for surface0 (package provided via overlays/hyprshade.nix)
  environment.systemPackages = with pkgs; (config.environment.systemPackages or []) ++ [hyprshade];

  # Add nixos0's SSH public key to surface0's authorized_keys
  users.users.${userConfig.user.username} = {
    openssh.authorizedKeys.keys = [
      # Default SSH key from system_modules/ssh.nix
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFvtrt7vEbXSyP8xuOfsfNGgC99Y98s1fmBIp3eZP4zx popcat19@nixos"
      # nixos0's SSH public key for SSH access from nixos0 to surface0
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFvtrt7vEbXSyP8xuOfsfNGgC99Y98s1fmBIp3eZP4zx popcat19@nixos0"
    ];
  };
}
