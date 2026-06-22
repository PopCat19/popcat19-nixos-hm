# services.nix
#
# Purpose: Configure user-level services for media, storage, and clipboard
#
# This module:
# - Enables media player D-Bus and MPRIS proxy
# - Configures automatic removable media mounting
# - Enables audio effects and clipboard history
_: {
  services = {
    cliphist.enable = true;
    easyeffects.enable = true;
    hyprsunset = {
      enable = true;
      settings.profile = [{
        time = "00:00";
        temperature = 3200;
      }];
    };
    mpris-proxy.enable = true;
    playerctld.enable = true;
    udiskie.enable = true;
  };
}
