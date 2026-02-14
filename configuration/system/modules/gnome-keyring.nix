# gnome-keyring.nix
#
# Purpose: Enable GNOME Keyring as the Secret Service provider
#
# This module:
# - Enables GNOME Keyring for credential storage
# - Configures D-Bus for keyring components
# - Disables SSH agent in favor of GNOME Keyring's
_: {
  programs.ssh.startAgent = false;

  security.polkit.enable = true;

  services.dbus.enable = true;
  services.gnome.gnome-keyring.enable = true;
}
