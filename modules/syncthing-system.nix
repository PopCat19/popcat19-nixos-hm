{ pkgs, config, lib, ... }:

let
  # Syncthing configuration constants
  syncthingUser = "popcat19";
  syncthingPaths = {
    shared = "/home/${syncthingUser}/syncthing-shared";
    passwords = "/home/${syncthingUser}/Passwords";
    dataDir = "/home/${syncthingUser}/.local/share/syncthing";
    configDir = "/home/${syncthingUser}/.config/syncthing";
  };
in
{
  # System-level syncthing service configuration
  services.syncthing = {
    enable = true;
    user = syncthingUser;
    group = "users";
    openDefaultPorts = true;
    dataDir = syncthingPaths.dataDir;
    configDir = syncthingPaths.configDir;
    settings = {
      devices = {
        "remote-device" = {
          id = "QP7SCT2-7XQTOK3-WTTSZ5T-T6BH4EZ-IA7VEIQ-RUQO5UV-FWWRF5L-LDQXTAS";
          name = "Remote Device";
          addresses = [ "dynamic" ];
        };
      };
      folders = {
        keepass-vault = {
          id = "keepass-vault";
          label = "KeePass Vault";
          path = syncthingPaths.passwords;
          devices = [ "remote-device" ];
          type = "sendreceive";
          rescanIntervalS = 60;
          ignorePerms = true;
        };
        syncthing-shared = {
          id = "syncthing-shared";
          label = "Syncthing Shared";
          path = syncthingPaths.shared;
          devices = [ "remote-device" ];
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
      22000  # Syncthing sync protocol
      8384   # Syncthing web UI
    ];
    allowedUDPPorts = [
      22000  # Syncthing sync protocol
      21027  # Syncthing discovery
    ];
  };
}