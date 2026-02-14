# syncthing.nix
#
# Purpose: Configure Syncthing directories and activation script
#
# This module:
# - Creates Syncthing shared and password directories
# - Sets up data and config directory paths
{
  lib,
  userConfig,
  ...
}:
let
  syncthingPaths = {
    configDir = "${userConfig.directories.home}/.config/syncthing";
    dataDir = "${userConfig.directories.home}/.local/share/syncthing";
    passwords = "${userConfig.directories.home}/Passwords";
    shared = userConfig.directories.syncthing;
  };
in
{
  home.activation.createSyncthingDirs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p ${syncthingPaths.shared}
    mkdir -p ${syncthingPaths.dataDir}
    mkdir -p ${syncthingPaths.passwords}
  '';
}
