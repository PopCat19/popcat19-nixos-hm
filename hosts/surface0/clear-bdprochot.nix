{ config, lib, pkgs, ... }:

with lib;

let
  msr-tools = pkgs.msr-tools;
in
{
  systemd.services.clear-bdprochot = {
    description = "Clear BD-PROCHOT bit in MSR 0x1FC";
    wantedBy    = [ "multi-user.target" ];
    after       = [ "systemd-modules-load.service" ];
    serviceConfig = {
      Type      = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.bash}/bin/bash -c '" +
        "old=$(${msr-tools}/bin/rdmsr 0x1FC) && " +
        "new=$((0x$old & 0xFFFFE)) && " +
        "${msr-tools}/bin/wrmsr 0x1FC \"$new\" && " +
        "echo \"BD-PROCHOT cleared (old: 0x$old → new: 0x$new)\"" +
        "'";
      # Run as root
      User  = "root";
      Group = "root";
    };
  };

  # Ensure the msr module is loaded
  boot.kernelModules = [ "msr" ];
}
