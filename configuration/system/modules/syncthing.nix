# syncthing.nix
#
# Purpose: Configure Syncthing file synchronization service
#
# This module:
# - Enables Syncthing service for the configured user
# - Configures device connections and folder sync
# - Opens firewall ports for sync protocol
{ userConfig, ... }:
let
  syncthingPaths = {
    configDir = "${userConfig.directories.home}/.config/syncthing";
    dataDir = "${userConfig.directories.home}/.local/share/syncthing";
    passwords = "${userConfig.directories.home}/Passwords";
    shared = userConfig.directories.syncthing;
  };

  syncthingUser = userConfig.username;

  devices = [
    "nixos0"
    "s23u"
    "surface0"
    "thinkpad0"
  ];

  piDevices = [
    "nixos0"
    # "klipper"  # TODO: add once Pi 4B is syncthing-enabled and device ID known
  ];
in
{
  networking.firewall = {
    allowedTCPPorts = [
      22000
      8384
    ];
    allowedUDPPorts = [
      21027
      22000
    ];
  };

  services.syncthing = {
    enable = true;
    group = "users";
    openDefaultPorts = true;
    settings = {
      devices = {
        "nixos0" = {
          addresses = [ "dynamic" ];
          id = "K6FLBMQ-5CJEX4X-VL4KETN-7AYJQW5-5VTXJWY-CLRMKBV-TGXIU26-WUY74QZ";
          name = "nixos0";
        };
        "s23u" = {
          addresses = [ "dynamic" ];
          id = "QP7SCT2-7XQTOK3-WTTSZ5T-T6BH4EZ-IA7VEIQ-RUQO5UV-FWWRF5L-LDQXTAS";
          name = "s23u";
        };
        "surface0" = {
          addresses = [ "dynamic" ];
          id = "5HCOSXJ-N56FEEI-VIUQRUV-S2LCQTM-AZK4DSC-5AOSNYF-7RQTTZM-6VOJYAN";
          name = "surface0";
        };
        "thinkpad0" = {
          addresses = [ "dynamic" ];
          id = "77NUF7I-XOXG3XA-LZDKCTC-ORPOQYO-4YBTFUW-RKIHOOZ-UYP7VOP-RBRUWQV";
          name = "thinkpad0";
        };
      };
      folders = {
        keepass-vault = {
          inherit devices;
          id = "keepass-vault";
          ignorePerms = true;
          label = "KeePass Vault";
          path = syncthingPaths.passwords;
          rescanIntervalS = 60;
          type = "sendreceive";
        };
        syncthing-shared = {
          inherit devices;
          id = "syncthing-shared";
          ignorePerms = true;
          label = "Syncthing Shared";
          path = syncthingPaths.shared;
          rescanIntervalS = 300;
          type = "sendreceive";
        };
        pi-klipper = {
          devices = piDevices;
          id = "pi-klipper";
          ignorePerms = true;
          label = "Pi Klipper";
          path = "${"${syncthingPaths.shared}"}/pi-klipper";
          rescanIntervalS = 30;
          type = "sendreceive";
        };
      };
      options = {
        globalAnnounceEnabled = true;
        localAnnounceEnabled = true;
        relaysEnabled = true;
      };
    };
    user = syncthingUser;
    inherit (syncthingPaths) configDir dataDir;
  };
}
