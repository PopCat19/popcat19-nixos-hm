# builders.nix
#
# Purpose: Configure remote Nix builder hosts for distributed builds
#
# This module:
# - Enables distributed builds for offloading compilation
# - Imports builder definitions from centralized configuration
# - Configures SSH keys for builder authentication
#
# Import this module on hosts that should use remote builders.
# Builder hosts (e.g., nixos0) do not need this module.
_: {
  nix.distributedBuilds = true;
  nix.extraOptions = ''
    builders-use-substitutes = true
  '';

  # Note: To use builders, add them to nix.buildMachines in your host config:
  # nix.buildMachines = [
  #   {
  #     hostName = "popcat19-nixos0";
  #     sshUser = "popcat19";
  #     system = "x86_64-linux";
  #     maxJobs = 8;
  #     speedFactor = 2;
  #     supportedFeatures = [ "kvm" "big-parallel" "nixos-test" "benchmark" ];
  #     mandatoryFeatures = [ ];
  #   }
  # ];
}
