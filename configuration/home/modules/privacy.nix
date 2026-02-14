# privacy.nix
#
# Purpose: Configures privacy and security tools.
#
# This module:
# - Installs KeePassXC password manager
# - Creates wrapper script for database auto-open
# - Ensures passwords directory exists

{
  pkgs,
  lib,
  userConfig,
  ...
}:
let
  passwordsDir = "${userConfig.directories.home}/Passwords";
  keepassDb = "${passwordsDir}/keepass.kdbx";

  kpxcWrapper = pkgs.writeShellScriptBin "kpxc" ''
    set -e
    DB="${keepassDb}"
    if [ -f "$DB" ]; then
      exec ${pkgs.keepassxc}/bin/keepassxc "$DB" "$@"
    else
      exec ${pkgs.keepassxc}/bin/keepassxc "$@"
    fi
  '';
in
{
  home.activation.createPasswordsDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p ${passwordsDir}
  '';
  home.packages = [
    kpxcWrapper
    pkgs.keepassxc
  ];
}
