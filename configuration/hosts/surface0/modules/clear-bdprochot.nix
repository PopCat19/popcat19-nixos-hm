# clear-bdprochot.nix
#
# Purpose: Clear BD-PROCHOT bit to prevent thermal throttling issues
#
# This module:
# - Creates systemd service to clear BD-PROCHOT on boot
# - Ensures MSR module is loaded
{
  pkgs,
  ...
}:
let
  inherit (pkgs) msr-tools;
in
{
  systemd.services.clear-bdprochot = {
    description = "Clear BD-PROCHOT bit in MSR 0x1FC";
    wantedBy = [ "multi-user.target" ];
    after = [ "systemd-modules-load.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart =
        "${pkgs.bash}/bin/bash -c '"
        + "old=$(${msr-tools}/bin/rdmsr 0x1FC) && "
        + "new=$((0x$old & 0xFFFFE)) && "
        + "${msr-tools}/bin/wrmsr 0x1FC \"$new\" && "
        + "echo \"BD-PROCHOT cleared (old: 0x$old → new: 0x$new)\""
        + "'";
      User = "root";
      Group = "root";
    };
  };

  boot.kernelModules = [ "msr" ];
}
