# OpenSSH Server Configuration Module
#
# Purpose: Enable and configure OpenSSH server for remote system access
# Dependencies: openssh, nixpkgs
# Related: networking.nix, services.nix
#
# This module:
# - Enables OpenSSH server service
# - Configures password authentication for user access
# - Permits root login for administrative access
# - Integrates with system firewall rules
{pkgs, ...}: {
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = yes;
      PermitRootLogin = "yes";
    };
  };
}