# agenix.nix
#
# Purpose: Configure agenix for secret management
#
# This module:
# - Configures age identity for decryption
# - Defines system-level secrets
{
  pkgs,
  userConfig,
  inputs,
  ...
}:
{
  environment.systemPackages = [
    inputs.agenix.packages.${pkgs.system}.default
  ];

  age = {
    identityPaths = [
      "/home/${userConfig.username}/.ssh/id_ed25519"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_rsa_key"
    ];

    secrets = {
      zrok-share-token = {
        file = ../../secrets/zrok-share-token.age;
        owner = userConfig.username;
        group = "users";
        mode = "400";
      };
    };
  };
}
