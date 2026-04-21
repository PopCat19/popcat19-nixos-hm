# ssh.nix
#
# Purpose: Enable and configure OpenSSH server for remote system access
#
# This module:
# - Enables OpenSSH server service
# - Configures password authentication for user access
# - Permits root login for administrative access
_: {
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = true;
      PermitRootLogin = "yes";
    };
  };
}
