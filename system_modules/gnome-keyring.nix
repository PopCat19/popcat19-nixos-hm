{
  config,
  pkgs,
  lib,
  ...
}: {
  # Enable GNOME Keyring globally (Secret Service provider)
  services.gnome.gnome-keyring.enable = true;

  # Ensure D-Bus is available for the keyring components
  services.dbus.enable = true;

  # Prefer GNOME Keyring's SSH agent over the built-in one
  programs.ssh = {
    startAgent = false;
  };

  # Optional: make sure Polkit is enabled (many desktops expect it)
  security.polkit.enable = true;
}
