{ lib, pkgs, ... }:

let
  # Import wallpaper.nix to inherit its functionality
  wallpaperModule = import ../hypr_config/wallpaper.nix { inherit lib pkgs; };

  # Walrs package from overlays
  walrs = pkgs.callPackage ../overlays/walrs.nix {};

  # System templates directory (if exists)
  systemTemplates = "/usr/share/walrs/templates";

in {
  home.packages = [ walrs ];

  # Inherit wallpaper images from wallpaper.nix
  home.file.".config/walrs/wallpapers" = {
    source = wallpaperModule.wallpaperDir;
    recursive = true;
  };

  # Create templates directory
  home.file.".config/walrs/templates/.gitkeep" = {
    text = "";
  };

  # Basic walrs configuration
  home.file.".config/walrs/config" = {
    text = ''
      # Walrs configuration
      # Add configuration options here as needed
    '';
  };

  # Expose wallpaper images for use in scripts
  home.sessionVariables = {
    WALLPAPER_DIR = "${wallpaperModule.wallpaperDir}";
    WALRS_CACHE_DIR = "$HOME/.cache/wal";
  };
}