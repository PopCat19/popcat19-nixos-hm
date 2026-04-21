# services.nix
#
# Purpose: Configure system-level services and daemons
#
# This module:
# - Configures journald log retention
# - Disables systemd coredumps
# - Enables input device support
# - Sets up udev rules for brightness control
# - Enables D-Bus, UDisks2, Flatpak, and GVFS
{ pkgs, ... }:
{
  security.polkit.enable = true;
  security.rtkit.enable = true;

  # Disable coredumps to save disk space
  systemd.coredump.enable = false;

  services.dbus.enable = true;
  services.flatpak.enable = true;
  services.gvfs.enable = true;
  services.journald.extraConfig = ''
    MaxRetentionSec=3day
    SystemMaxUse=500M
    SystemKeepFree=100M
    Compress=yes
    ForwardToSyslog=no
    ForwardToWall=no
  '';
  services.libinput.enable = true;
  services.udisks2.enable = true;
  services.upower.enable = true;

  services.udev.extraRules = ''
    SUBSYSTEM=="backlight", ACTION=="add", RUN+="${pkgs.coreutils}/bin/chgrp video /sys/class/backlight/%k/brightness"
    SUBSYSTEM=="backlight", ACTION=="add", RUN+="${pkgs.coreutils}/bin/chmod g+w /sys/class/backlight/%k/brightness"
    SUBSYSTEM=="leds", ACTION=="add", RUN+="${pkgs.coreutils}/bin/chgrp video /sys/class/leds/%k/brightness"
    SUBSYSTEM=="leds", ACTION=="add", RUN+="${pkgs.coreutils}/bin/chmod g+w /sys/class/leds/%k/brightness"
  '';
}
