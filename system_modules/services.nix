{ pkgs, ... }:

{
  # System services configuration
  
  # Journald configuration
  services.journald.extraConfig = ''
    MaxRetentionSec=3day
    SystemMaxUse=500M
    SystemKeepFree=100M
    Compress=yes
    ForwardToSyslog=no
    ForwardToWall=no
  '';

  # Input services
  services.libinput.enable = true;

  # System services
  services = {
    # Storage / Packaging
    udisks2.enable = true;
    flatpak.enable = true;

    # Hardware
    upower.enable = true;

    # D-Bus service
    dbus.enable = true;
  };

  # Security & authentication
  security.polkit.enable = true;
  security.rtkit.enable = true;
}