# glance.nix
#
# Purpose: Configures Glance self-hosted dashboard.
#
# This module:
# - Enables Glance dashboard service

_: {
  services.glance.enable = true;
}
