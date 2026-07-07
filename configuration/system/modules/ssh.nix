# ssh.nix
#
# Purpose: Enable and configure OpenSSH server for remote system access
#
# This module:
# - Enables OpenSSH server service
# - Disables password authentication (key-only SSH)
# - Permits root login with key only (prohibit-password)
_: {
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "prohibit-password";
    };
  };
}
