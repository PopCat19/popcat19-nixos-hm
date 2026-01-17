{ pkgs, ... }:
{
  services.pipewire = {
    enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    pulse.enable = true;
    # Extra configuration for HDMI audio support
    extraConfig.pipewire."91-hdmi-audio" = {
      "context.properties" = {
        "default.clock.rate" = 48000;
        "default.clock.allowed-rates" = [
          44100
          48000
          96000
        ];
      };
    };
  };

  # Ensure ALSA utilities are available for audio management
  environment.systemPackages = with pkgs; [
    alsa-utils
  ];
}
