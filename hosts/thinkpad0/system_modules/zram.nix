# ThinkPad ZRAM Configuration Module
#
# Purpose: Configure ZRAM swap for improved memory management on ThinkPad.
# Dependencies: None
# Related: system_modules/core_modules/boot.nix
#
# This module:
# - Enables ZRAM compressed swap
# - Configures ZRAM to use up to 100% of RAM size
# - Improves performance on systems with limited memory
{
  # ZRAM Configuration
  zramSwap = {
    enable = true;
    memoryPercent = 100; # Compress up to 100% of RAM size
  };
}
