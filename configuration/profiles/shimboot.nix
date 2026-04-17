# shimboot.nix
#
# Purpose: Shimboot profile preset for ChromeOS devices with dedede board
#
# This profile:
# - Imports shimboot chromeos base configuration
# - Includes desktop environment (inclusive for usability on low hardware)
# - Configures for x86_64 ChromeOS devices
{ userConfig, inputs, ... }:
{
  imports = [
    # Import shimboot chromeos module and pass userConfig via _module.args
    inputs.shimboot.nixosModules.chromeos
  ];

  # Re-export userConfig for shimboot modules
  _module.args.userConfig = userConfig;

  home-manager.users.${userConfig.username} = {
    imports = [ ../home/modules ];
  };
}
