# System-level privacy: use KWallet for PAM; KeepassXC managed manually (SSI disabled)
{ config, pkgs, lib, ... }:

{
  # DBus may be used by desktop components; fine to keep enabled.
  services.dbus.enable = true;

  # Enable KWallet PAM integration so wallet can unlock at session start (e.g., via SDDM/login).
  security.pam.services.kwallet.enable = true;

  # Do not declare any Secret Service provider here. KeePassXC will be configured manually
  # by the user, and Secret Service integration remains disabled per request.
}