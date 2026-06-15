# printer.nix
#
# Purpose: Klipper firmware service with mutable printer.cfg
#
# This module:
# - Enables Klipper with mutable config in /var/lib/moonraker/config
#   (shared with Moonraker so Mainsail file editor works)
# - Seeds a minimal printer.cfg on first boot
# - Configures tmpfiles for printer data
# - Grants Moonraker D-Bus access to systemd for shutdown/reboot
{
  userConfig,
  ...
}:
let
  printerCfgDir = "/var/lib/moonraker/config";
  printerCfgFile = "${printerCfgDir}/printer.cfg";
  printerDataHome = userConfig.directories.home;
in
{
  systemd.tmpfiles.rules = [
    "d ${printerCfgDir} 2775 moonraker klipper -"
    "d /var/lib/moonraker/gcodes 0775 moonraker moonraker -"
    "f /var/log/klipper.log 0644 klipper klipper -"
    "f /var/log/moonraker.log 0644 moonraker moonraker -"
    "d ${printerDataHome}/printer_data 0775 ${userConfig.username} klipper -"
    "d ${printerDataHome}/printer_data/logs 0775 ${userConfig.username} klipper -"
  ];

  # Allow moonraker to call systemd over D-Bus for shutdown/reboot via Mainsail
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (action.id == "org.freedesktop.systemd1.manage-units" &&
          subject.user == "moonraker") {
        return polkit.Result.YES;
      }
    });
  '';

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

  # Symlink printer.cfg from syncthing pool so edits propagate across hosts
  systemd.services.klipper.preStart =
    let
      syncthingCfg = "${userConfig.directories.syncthing}/pi-klipper/printer_data/config/printer.cfg";
    in
    ''
      mkdir -p ${printerCfgDir}
      if [ -f "${syncthingCfg}" ]; then
        ln -sf "${syncthingCfg}" ${printerCfgFile}
      fi
      if [ ! -e ${printerCfgFile} ]; then
        cat > ${printerCfgFile} << 'SEED'
      # Klipper printer.cfg — seeded by NixOS on first boot
      #
      # Full config is in ~/syncthing-shared/pi-klipper/printer.cfg on nixos0.
      # Copy it here or configure via Mainsail UI at http://klipper.local

      [mcu]
      serial: /dev/serial/by-id/usb-Klipper_stm32g0b1xx*

      [virtual_sdcard]
      path: /var/lib/moonraker/gcodes
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
}
