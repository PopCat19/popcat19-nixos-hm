{
  zrok = {
    enable = false;
  };
  sillytavern = {
    enable = false;
  };
  odysseus = {
    enable = false;
    environmentFile = null;
    openFirewall = false;
  };
  klipper = {
    enable = false;
    wifi = {
      ssid = "Beave_Net_IoT";
      psk = "REDACTED";
    };
    ap = {
      enable = true;
      ssid = "Klipper-Setup";
      subnet = "192.168.50.1/24";
      psk = "REDACTED";
    };
  };
}
