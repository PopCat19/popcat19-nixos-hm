# zram.nix
#
# Purpose: Configure ZRAM swap for improved memory management
#
# This module:
# - Enables ZRAM compressed swap
# - Configures ZRAM to use up to 100% of RAM size
{
  zramSwap = {
    enable = true;
    memoryPercent = 100;
  };
}
