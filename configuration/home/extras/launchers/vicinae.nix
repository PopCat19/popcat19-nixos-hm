# Vicinae Launcher Module
#
# Purpose: Configure Vicinae application launcher with systemd service
# Dependencies: inputs.vicinae | None
# Related: fuzzel-config.nix, services.nix
#
# This module:
# - Enables Vicinae launcher application
# - Configures systemd service with auto-start
# - Sets up Wayland layer shell mode
# - Theme settings handled by Stylix
{inputs, ...}: {
  imports = [inputs.vicinae.homeManagerModules.default];

  services.vicinae = {
    enable = true;

    systemd = {
      enable = true;
      autoStart = true;
      environment = {
        USE_LAYER_SHELL = "1";
      };
    };

    settings = {
      close_on_focus_loss = false;
    };
  };
}
