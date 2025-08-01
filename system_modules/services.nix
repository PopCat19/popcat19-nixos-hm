{ pkgs, ... }:

{
  # **SYSTEM SERVICES CONFIGURATION**
  # Defines various system services and their settings.
  
  # **JOURNALD CONFIGURATION**
  services.journald.extraConfig = ''
    # Rotate after 3 days
    MaxRetentionSec=3day
    # Size & free-space limits
    SystemMaxUse=500M
    SystemKeepFree=100M
    Compress=yes
    # Do not forward
    ForwardToSyslog=no
    ForwardToWall=no
  '';

  # **INPUT SERVICES**
  services.libinput.enable = true;

  # **SYSTEM SERVICES**
  services = {
    # Storage / Packaging
    udisks2.enable = true;
    flatpak.enable = true;

    # Hardware
    hardware.openrgb.enable = true;

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

  # **FLATPAK FLATHUB CONFIGURATION**
  # Add Flathub repository via systemd service
  systemd.services.flatpak-repo = {
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.flatpak ];
    script = ''
      flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    '';
  };

  # **SECURITY & AUTHENTICATION**
  security.polkit.enable = true;
  security.rtkit.enable = true;
}