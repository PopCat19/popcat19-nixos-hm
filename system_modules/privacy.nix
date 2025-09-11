# System-level privacy: GNOME Keyring used; KWallet removed
{
  config,
  pkgs,
  lib,
  ...
}: {
  # DBus may be used by desktop components; keep enabled.
  services.dbus.enable = true;
}
