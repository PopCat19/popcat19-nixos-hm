{
  pkgs,
  lib,
  ...
}: {
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

  # Surface-specific services
  services.iptsd.enable = lib.mkDefault true;

  services.auto-cpufreq = {
    enable = true;
    settings = {
      battery = {
        governor = "schedutil";
        turbo = "auto";
        scaling_min_freq = 400000;
        scaling_max_freq = 4200000;
      };
      charger = {
        governor = "performance";
        turbo = "auto";
        scaling_min_freq = 800000;
        scaling_max_freq = 4200000;
      };
    };
  };

  # Power/profile services
  services.power-profiles-daemon.enable = false;
  services.tlp.enable = false;

  # Firmware update service
  services.fwupd.enable = true;

  # Udev rules for Surface hardware
  services.udev.extraRules = ''
    # Surface touch and pen devices
    SUBSYSTEM=="input", ATTRS{name}=="*Surface*", MODE="0664", GROUP="input"

    # Surface camera devices
    SUBSYSTEM=="video4linux", ATTRS{name}=="*Surface*", MODE="0664", GROUP="video"

    # Surface aggregator devices
    SUBSYSTEM=="surface_aggregator", MODE="0664", GROUP="users"

    # Surface battery and power devices
    SUBSYSTEM=="power_supply", ATTRS{name}=="*Surface*", MODE="0664", GROUP="users"

    # Brightness control permissions
    SUBSYSTEM=="backlight", ACTION=="add", RUN+="${pkgs.coreutils}/bin/chgrp video /sys/class/backlight/%k/brightness"
    SUBSYSTEM=="backlight", ACTION=="add", RUN+="${pkgs.coreutils}/bin/chmod g+w /sys/class/backlight/%k/brightness"
    SUBSYSTEM=="leds", ACTION=="add", RUN+="${pkgs.coreutils}/bin/chgrp video /sys/class/leds/%k/brightness"
    SUBSYSTEM=="leds", ACTION=="add", RUN+="${pkgs.coreutils}/bin/chmod g+w /sys/class/leds/%k/brightness"

    # WiFi power management and stability rules
    ACTION=="add", SUBSYSTEM=="net", KERNEL=="wlp*", RUN+="${pkgs.iw}/bin/iw dev $name set power_save off"
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x11ab", ATTR{device}=="0x2b38", ATTR{power/control}="on"

    # Disable USB autosuspend for WiFi devices to prevent disconnections
    ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="11ab", ATTRS{idProduct}=="2b38", ATTR{power/autosuspend}="-1"
  '';

  # Audio / PipeWire
  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # System services
  services.udisks2.enable = true;
  services.flatpak.enable = true;
  services.upower.enable = true;
  services.dbus.enable = true;

  # Xserver DPI
  services.xserver = {
    dpi = 200;
  };

  # Security & authentication
  security.polkit.enable = true;
  security.rtkit.enable = true;

  # TPM / Secure Boot support
  security.tpm2 = {
    enable = true;
    pkcs11.enable = true;
    tctiEnvironment.enable = true;
  };

  # WiFi stability systemd service
  systemd.services.wifi-powersave-off = {
    description = "Turn off WiFi power saving";
    wantedBy = ["multi-user.target"];
    after = ["network.target"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.bash}/bin/bash -c 'for i in /sys/class/net/wlp*; do [ -e $i/device/power/control ] && echo on > $i/device/power/control; done'";
    };
  };
}
