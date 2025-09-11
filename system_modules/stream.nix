{
  pkgs,
  lib,
  ...
}: {
  # Game streaming services configuration

  services = {
    # Sunshine game streaming server
    sunshine = {
      enable = lib.mkDefault true;
      autoStart = true;
      capSysAdmin = true;
      openFirewall = true;
      settings.output_name = "DP-3";
    };
  };
}
