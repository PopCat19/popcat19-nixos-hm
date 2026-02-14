# services.nix
#
# Purpose: System services configuration for Surface device
#
# This module:
# - Configures audio, input, and system services
# - Sets up udev rules for Surface hardware
{
  pkgs,
  lib,
  ...
}:
{
  services.journald.extraConfig = ''
    MaxRetentionSec=3day
    SystemMaxUse=500M
    SystemKeepFree=100M
    Compress=yes
    ForwardToSyslog=no
    ForwardToWall=no
  '';

  services.libinput.enable = true;

  services.iptsd.enable = lib.mkDefault true;

  services.fwupd.enable = true;

  services.udev.packages = [ pkgs.ddcutil ];

  services.udev.extraRules = ''
    SUBSYSTEM=="input", ATTRS{name}=="*Surface*", MODE="0664", GROUP="input"
    SUBSYSTEM=="video4linux", ATTRS{name}=="*Surface*", MODE="0664", GROUP="video"
    SUBSYSTEM=="surface_aggregator", MODE="0664", GROUP="users"
    SUBSYSTEM=="power_supply", ATTRS{name}=="*Surface*", MODE="0664", GROUP="users"
    SUBSYSTEM=="backlight", ACTION=="add", RUN+="${pkgs.coreutils}/bin/chgrp video /sys/class/backlight/%k/brightness"
    SUBSYSTEM=="backlight", ACTION=="add", RUN+="${pkgs.coreutils}/bin/chmod g+w /sys/class/backlight/%k/brightness"
    SUBSYSTEM=="leds", ACTION=="add", RUN+="${pkgs.coreutils}/bin/chgrp video /sys/class/leds/%k/brightness"
    SUBSYSTEM=="leds", ACTION=="add", RUN+="${pkgs.coreutils}/bin/chmod g+w /sys/class/leds/%k/brightness"
    ACTION=="add", SUBSYSTEM=="net", KERNEL=="wlp*", RUN+="${pkgs.iw}/bin/iw dev $name set power_save off"
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x11ab", ATTR{device}=="0x2b38", ATTR{power/control}="on"
    ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="11ab", ATTRS{idProduct}=="2b38", ATTR{power/autosuspend}="-1"
    KERNEL=="i2c-[0-9]*", GROUP="i2c", MODE="0660"
  '';

  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  services.udisks2.enable = true;
  services.flatpak.enable = true;
  services.upower.enable = true;
  services.dbus.enable = true;

  services.xserver = {
    dpi = 200;
  };

  security.polkit.enable = true;
  security.rtkit.enable = true;
}
