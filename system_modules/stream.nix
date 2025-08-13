{ pkgs, ... }:

{
  # Game streaming services configuration
  
  services = {
    # Sunshine game streaming server
    sunshine = {
      enable = true;
      autoStart = true;
      capSysAdmin = true;
      openFirewall = true;
      settings.output_name = "DP-3";
    };
  };
}