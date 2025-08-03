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
    hardware.openrgb.enable = true;
    upower.enable = true;

    # Game streaming
    sunshine = {
      enable = true;
      autoStart = true;
      capSysAdmin = true;
      openFirewall = true;
      settings.output_name = "1";
    };

    # D-Bus service
    dbus.enable = true;
  };

  # Security & authentication
  security.polkit.enable = true;
  security.rtkit.enable = true;
}