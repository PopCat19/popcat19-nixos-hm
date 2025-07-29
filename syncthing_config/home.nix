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
  # User-level directory creation and configuration
  home.activation.createSyncthingDirs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p ${syncthingPaths.shared}
    mkdir -p ${syncthingPaths.dataDir}
    mkdir -p ${syncthingPaths.passwords}
  '';
}