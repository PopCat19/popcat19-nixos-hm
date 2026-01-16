# Host-specific home configuration for surface0
{userConfig, ...}: {
  # Basic home configuration
  home.username = userConfig.user.username;
  home.homeDirectory = userConfig.directories.home;
  home.stateVersion = "24.05";

  # Import the central home configuration
  imports = [
    ../../configuration/home/home.nix
  ];

  # Host-specific monitor configuration (overrides central config)
  home.file.".config/hypr/monitors.conf".source = ./hypr_config/monitors.conf;
}
