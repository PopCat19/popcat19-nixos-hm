# vicinae.nix
#
# Purpose: Configure Vicinae application launcher with systemd service
#
# This module:
# - Enables Vicinae launcher application
# - Configures systemd service with auto-start
# - Sets up Wayland layer shell mode
{ inputs, ... }:
{
  imports = [ inputs.vicinae.homeManagerModules.default ];

  services.vicinae = {
    enable = true;
    settings = {
      close_on_focus_loss = false;
    };
    systemd = {
      autoStart = true;
      enable = true;
      environment = {
        USE_LAYER_SHELL = "1";
      };
    };
  };
}
