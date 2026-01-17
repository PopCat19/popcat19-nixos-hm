{ userConfig, ... }:
let
  # Syncthing configuration constants
  syncthingUser = userConfig.user.username;
  syncthingPaths = {
    shared = userConfig.directories.syncthing;
    passwords = "${userConfig.directories.home}/Passwords";
    dataDir = "${userConfig.directories.home}/.local/share/syncthing";
    configDir = "${userConfig.directories.home}/.config/syncthing";
  };
in
{
  # System-level syncthing service configuration
  services.syncthing = {
    enable = true;
    user = syncthingUser;
    group = "users";
    openDefaultPorts = true;
    inherit (syncthingPaths) dataDir;
    inherit (syncthingPaths) configDir;
    settings = {
      devices = {
        "nixos0" = {
          id = "K6FLBMQ-5CJEX4X-VL4KETN-7AYJQW5-5VTXJWY-CLRMKBV-TGXIU26-WUY74QZ";
          name = "nixos0";
          addresses = [ "dynamic" ];
        };
        "surface0" = {
          id = "5HCOSXJ-N56FEEI-VIUQRUV-S2LCQTM-AZK4DSC-5AOSNYF-7RQTTZM-6VOJYAN";
          name = "surface0";
          addresses = [ "dynamic" ];
        };
        "s23u" = {
          id = "QP7SCT2-7XQTOK3-WTTSZ5T-T6BH4EZ-IA7VEIQ-RUQO5UV-FWWRF5L-LDQXTAS";
          name = "s23u";
          addresses = [ "dynamic" ];
        };
        "thinkpad0" = {
          id = "77NUF7I-XOXG3XA-LZDKCTC-ORPOQYO-4YBTFUW-RKIHOOZ-UYP7VOP-RBRUWQV";
          name = "thinkpad0";
          addresses = [ "dynamic" ];
        };
      };
      folders = {
        keepass-vault = {
          id = "keepass-vault";
          label = "KeePass Vault";
          path = syncthingPaths.passwords;
          devices = [
            "surface0"
            "nixos0"
            "s23u"
            "thinkpad0"
          ];
          type = "sendreceive";
          rescanIntervalS = 60;
          ignorePerms = true;
        };
        syncthing-shared = {
          id = "syncthing-shared";
          label = "Syncthing Shared";
          path = syncthingPaths.shared;
          devices = [
            "surface0"
            "nixos0"
            "s23u"
            "thinkpad0"
          ];
          type = "sendreceive";
          rescanIntervalS = 300;
          ignorePerms = true;
        };
      };
      options = {
        globalAnnounceEnabled = true;
        localAnnounceEnabled = true;
        relaysEnabled = true;
      };
    };
  };

  # Firewall configuration for syncthing
  networking.firewall = {
    allowedTCPPorts = [
      22000 # Syncthing sync protocol
      8384 # Syncthing web UI
    ];
    allowedUDPPorts = [
      22000 # Syncthing sync protocol
      21027 # Syncthing discovery
    ];
  };
}
