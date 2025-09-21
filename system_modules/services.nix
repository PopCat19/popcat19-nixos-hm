{pkgs, ...}: {
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

  # Add udev rules to allow non-root brightness control (group=video, g+w)
  services.udev.extraRules = ''
    SUBSYSTEM=="backlight", ACTION=="add", RUN+="${pkgs.coreutils}/bin/chgrp video /sys/class/backlight/%k/brightness"
    SUBSYSTEM=="backlight", ACTION=="add", RUN+="${pkgs.coreutils}/bin/chmod g+w /sys/class/backlight/%k/brightness"
    SUBSYSTEM=="leds", ACTION=="add", RUN+="${pkgs.coreutils}/bin/chgrp video /sys/class/leds/%k/brightness"
    SUBSYSTEM=="leds", ACTION=="add", RUN+="${pkgs.coreutils}/bin/chmod g+w /sys/class/leds/%k/brightness"
  '';

  # System services
  services = {
    # Storage / Packaging
    udisks2.enable = true;
    flatpak.enable = true;

    # Hardware
    upower.enable = true;
    tlp.enable = true;

    # D-Bus service
    dbus.enable = true;
  };

  # Security & authentication
  security.polkit.enable = true;
  security.rtkit.enable = true;

  # Add Flathub repository automatically
  systemd.services.flatpak-repo = {
    wantedBy = ["multi-user.target"];
    after = [ "network-online.target" "mullvad-autoconnect.service" ];
    wants = [ "network-online.target" "mullvad-autoconnect.service" ];
    path = [pkgs.flatpak];
    script = ''
      flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    '';
  };
}
