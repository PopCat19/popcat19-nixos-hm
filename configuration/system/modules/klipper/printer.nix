# printer.nix
#
# Purpose: Klipper + Moonraker + Mainsail 3D printer service stack
#
# This module:
# - Enables Klipper with mutable printer.cfg (editable at /var/lib/klipper/printer.cfg)
# - Configures Klipper for BTT SKR Mini E3 V3 (USB: /dev/serial/by-id/usb-Klipper_stm32g0b1xx_*)
# - Enables Moonraker API server on port 7125 with trusted clients from LAN
# - Enables Mainsail web UI on port 80 via nginx
# - Adds popcat19 and klipper users to shared klipper group
# - Configures syncthing folder for printer.cfg sync
{
  userConfig,
  ...
}:
let
  printerCfgDir = "/var/lib/klipper";
  printerCfgFile = "${printerCfgDir}/printer.cfg";
in
{
  # ------------------------------------------------------------------
  # Users and groups — klipper service user + shared group for syncthing
  # ------------------------------------------------------------------
  users.users = {
    klipper = {
      isSystemUser = true;
      group = "klipper";
      home = "/home/klipper";
      createHome = true;
    };
    moonraker = {
      isSystemUser = true;
      group = "moonraker";
      home = "/home/moonraker";
      createHome = true;
    };
    ${userConfig.username} = {
      extraGroups = [
        "klipper"
        "moonraker"
      ];
    };
  };

  users.groups = {
    klipper = { };
    moonraker = { };
  };

  # ------------------------------------------------------------------
  # Klipper — mutable config (editable at /var/lib/klipper/printer.cfg)
  # Uses Klipper's own user:group, realtime scheduling, IPC socket
  # ------------------------------------------------------------------
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

  # Seed printer.cfg on first boot if it doesn't exist
  #
  # The initial config includes only the [mcu] block so Klipper starts.
  # All axis, heater, probe, etc. config is added via the Mainsail/Fluidd
  # UI or by copying the full printer.cfg from ~/syncthing-shared/pi-klipper/.
  #
  # If you want the full config pre-seeded, set
  # services.klipper.mutableConfig = false and provide services.klipper.configFile
  # instead, pointing at a Nix-managed printer.cfg generated from
  # services.klipper.settings or an external file.
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
    path: /home/popcat19/printer_data/gcodes
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

  # ------------------------------------------------------------------
  # Moonraker — API server for Klipper, exposes port 7125
  # Trusts all LAN clients (192.168.0.0/16, 10.0.0.0/8)
  # ------------------------------------------------------------------
  services.moonraker = {
    enable = true;
    address = "0.0.0.0";
    port = 7125;
    allowSystemControl = true;
    settings = {
      authorization = {
        trusted_clients = [
          "127.0.0.0/8"
          "192.168.0.0/16"
          "10.0.0.0/8"
          "169.254.0.0/16"
          "172.16.0.0/12"
          "FC00::/7"
          "FE80::/10"
          "::1/128"
        ];
        cors_domains = [
          "*.lan"
          "*.local"
          "*://localhost"
          "*://localhost:*"
        ];
      };
      octoprint_compat = { };
      history = { };
      file_manager = {
        enable_object_processing = true;
      };
    };
  };

  # ------------------------------------------------------------------
  # Mainsail — web UI on port 80 via nginx
  # talks to Moonraker at localhost:7125
  # ------------------------------------------------------------------
  services.mainsail = {
    enable = true;
    hostName = "0.0.0.0";
  };

  # Increase nginx upload limit (for gcode files)
  services.nginx = {
    enable = true;
    clientMaxBodySize = "0";
  };

  systemd.tmpfiles.rules = [
    "d ${printerCfgDir} 2775 klipper klipper -"
    "d /home/popcat19/printer_data 0775 popcat19 klipper -"
    "d /home/popcat19/printer_data/gcodes 0775 popcat19 klipper -"
    "d /home/popcat19/printer_data/logs 0775 popcat19 klipper -"
  ];
}
