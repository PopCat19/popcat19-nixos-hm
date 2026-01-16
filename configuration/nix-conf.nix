# Nix Configuration Module
#
# Purpose: Configure Nix settings for gaming and system optimization
# Dependencies: aagl flake input
# Related: configuration/flake/modules/modules.nix
#
# This module:
# - Sets nix.settings from aagl nixConfig for optimized builds
{inputs}: {
  nix.settings = inputs.aagl.nixConfig;
}
