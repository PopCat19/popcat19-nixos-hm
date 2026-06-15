# moonraker.nix
#
# Purpose: Moonraker API server for Klipper
{
  config,
  ...
}: {
  services.moonraker = {
    enable = true;
    address = "0.0.0.0";
    port = 7125;
    allowSystemControl = true;
    settings = {
      server = {
        klippy_uds_address = config.services.klipper.apiSocket;
      };
      file_manager = {
        config_path = "/var/lib/klipper";
        log_path = "/var/log";
        enable_object_processing = true;
      };
      authorization = {
        trusted_clients = [
          "127.0.0.0/8"
          "192.168.0.0/16"
          "10.0.0.0/8"
          "169.254.0.0/16"
          "172.16.0.0/12"
          "FC00::/7"
          "FE80::/10"
          "::1/128"
        ];
        cors_domains = [
          "*.lan"
          "*.local"
          "*://localhost"
          "*://localhost:*"
        ];
      };
      octoprint_compat = { };
      history = { };
    };
  };
}
