# Helper Functions Module
#
# Purpose: Provides helper functions for system configuration
#
# This module:
# - Defines reusable helper functions for fish function wrappers
# - Provides utility functions for profile-specific configurations
# - Enables consistent patterns across the configuration
{ lib, userConfig, selectedProfile, ... }:
{
  # Helper function to create fish function wrappers
  # Usage: helpers.mkFishWrapper { name = "my-function"; source = ./my-function.fish; }
  helpers = {
    mkFishWrapper = { name, source }:
      lib.nameValuePair "fish/functions/${name}.fish" {
        inherit source;
      };

    # Helper to check if a profile is active
    isProfile = profile: selectedProfile == profile;

    # Helper to get profile-specific path
    getProfilePath = profilePath: "${profilePath}/${selectedProfile}";

    # Helper to conditionally include modules based on profile
    ifProfile = profile: module: lib.mkIf (selectedProfile == profile) module;
  };
}
