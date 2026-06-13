# printer.nix
#
# Purpose: Klipper firmware service with mutable printer.cfg
#
# This module:
# - Enables Klipper with mutable config in /var/lib/klipper
# - Seeds a minimal printer.cfg on first boot
# - Configures tmpfiles for printer data owned by the primary user
{
  userConfig,
  ...
}:
let
  printerCfgDir = "/var/lib/klipper";
  printerCfgFile = "${printerCfgDir}/printer.cfg";
  printerDataHome = userConfig.directories.home;
in
{
  services.klipper = {
    enable = true;
    user = "klipper";
    group = "klipper";
    mutableConfig = true;
    configDir = printerCfgDir;
    apiSocket = "/run/klipper/api";
    logFile = "/var/log/klipper.log";
    settings = { };
  };

  systemd.services.klipper.preStart = ''
    mkdir -p ${printerCfgDir}
    if [ ! -e ${printerCfgFile} ]; then
      cat > ${printerCfgFile} << 'SEED'
    # Klipper printer.cfg — seeded by NixOS on first boot
    #
    # Full config is in ~/syncthing-shared/pi-klipper/printer.cfg on nixos0.
    # Copy it here or configure via Mainsail UI at http://klipper.local

    [include mainsail.cfg]

    [mcu]
    serial: /dev/serial/by-id/usb-Klipper_stm32g0b1xx*

    [virtual_sdcard]
    path: ${printerDataHome}/printer_data/gcodes
    on_error_gcode: CANCEL_PRINT

    [printer]
    kinematics: cartesian
    max_velocity: 300
    max_accel: 3000
    max_z_velocity: 15
    max_z_accel: 100
    SEED
      chown klipper:klipper ${printerCfgFile}
      chmod 664 ${printerCfgFile}
    fi
  '';

  systemd.tmpfiles.rules = [
    "d ${printerCfgDir} 2775 klipper klipper -"
    "f /var/log/klipper.log 0644 klipper klipper -"
    "d ${printerDataHome}/printer_data 0775 ${userConfig.username} klipper -"
    "d ${printerDataHome}/printer_data/gcodes 0775 ${userConfig.username} klipper -"
    "d ${printerDataHome}/printer_data/logs 0775 ${userConfig.username} klipper -"
  ];
}
