# agenix.nix
#
# Purpose: Configure agenix for secret management
#
# This module:
# - Configures age identity for decryption
# - Defines system-level secrets, gated by feature flags
{
  pkgs,
  lib,
  userConfig,
  inputs,
  ...
}:
{
  environment.systemPackages = [
    inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  age = {
    identityPaths = [
      "/home/${userConfig.username}/.ssh/id_ed25519"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_rsa_key"
    ];

    secrets = lib.mkMerge [
      (lib.mkIf (userConfig.zrok.enable or false) {
        zrok-share-token = {
          file = ../../secrets/zrok-share-token.age;
          owner = userConfig.username;
          group = "users";
          mode = "400";
        };
      })

      (lib.mkIf (userConfig.sillytavern.enable or false) {
        sillytavern-password = {
          file = ../../secrets/sillytavern-password.age;
          owner = "sillytavern";
          group = "sillytavern";
          mode = "400";
        };
      })

      (lib.mkIf (userConfig.klipper.enable or false) {
        klipper-wifi-psk = {
          file = ../../secrets/klipper-wifi-psk.age;
          owner = userConfig.username;
          group = "users";
          mode = "400";
        };
        klipper-hashed-password = {
          file = ../../secrets/klipper-hashed-password.age;
          owner = "root";
          group = "root";
          mode = "400";
        };
      })
    ];
  };
}
