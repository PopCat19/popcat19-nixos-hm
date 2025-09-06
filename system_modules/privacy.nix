# System-level privacy adjustments for KeePassXC Secret Service on Hyprland
{ config, pkgs, lib, ... }:

{
  # DBus is required for the Secret Service API (org.freedesktop.secrets).
  services.dbus.enable = true;

  # Since we're on Hyprland (no KDE session), kwallet shouldn't be in use.
  # As a safeguard, mask KWallet autostart desktop files (best-effort).
  environment.etc."xdg/autostart/kwalletmanager5.desktop".text = "";
  environment.etc."xdg/autostart/kwalletd5.desktop".text = "";
}