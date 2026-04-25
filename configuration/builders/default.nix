# default.nix
#
# Purpose: Export Nix builder host configurations for distributed builds
#
# This module:
# - Defines remote builder hosts available in the network
# - Provides SSH host keys for trust-on-first-use verification
# - Documents builder capabilities and system features
#
# Usage: Import this module and add builders to nix.buildMachines
{
  nixos0 = {
    hostName = "popcat19-nixos0";
    sshUser = "popcat19";
    system = "x86_64-linux";
    maxJobs = 8;
    speedFactor = 2;
    supportedFeatures = [
      "kvm"
      "big-parallel"
      "nixos-test"
      "benchmark"
    ];
    mandatoryFeatures = [ ];
    # SSH host key for key verification (ed25519)
    # Retrieve with: ssh-keyscan -t ed25519 popcat19-nixos0
    sshHostPublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP1yA6beqNqxgrbiZF+J5rZZy2PtT9/+Gfym78xsnAkF root@nixos";
  };
}
