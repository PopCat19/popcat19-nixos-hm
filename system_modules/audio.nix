{ ... }:

{
  # **AUDIO CONFIGURATION**
  # Defines PipeWire audio system settings.
  services.pipewire = {
    enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    pulse.enable = true;
  };
}