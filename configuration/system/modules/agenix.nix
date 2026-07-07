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
      {
        user-password-hash = {
          file = ../../secrets/user-password-hash.age;
          owner = "root";
          group = "root";
          mode = "400";
        };

        searxng-secret-key = {
          file = ../../secrets/searxng-secret-key.age;
          owner = "root";
          group = "root";
          mode = "400";
        };
      }

      (lib.mkIf (userConfig.sillytavern.enable or false) {
        sillytavern-password = {
          file = ../../secrets/sillytavern-password.age;
          owner = "sillytavern";
          group = "sillytavern";
          mode = "400";
        };
      })
    ];
  };
}
