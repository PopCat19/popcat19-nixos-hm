{
  zrok = {
    enable = false;
  };
  sillytavern = {
    enable = false;
  };
  klipper = {
    enable = false;
    wifi = { };
    ap = {
      enable = true;
      ssid = "Klipper-Setup";
      subnet = "192.168.50.1/24";
    };
  };
}
