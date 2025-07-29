{ system, ... }:

let
  # Architecture detection
  isX86_64 = system == "x86_64-linux";
  isAarch64 = system == "aarch64-linux";
  
  # Architecture-specific acceleration settings
  ollamaAcceleration = if isX86_64 then "rocm" else null; # ROCm only on x86_64
  
in
{
  # **SYSTEM SERVICES**
  # Enables user-level services.
  services = {
    # Media Control services.
    playerctld.enable = true; # D-Bus interface for media players.
    mpris-proxy.enable = true; # MPRIS proxy for media players.

    # Storage Management.
    udiskie.enable = true; # Automount removable media.

    # Audio Effects.
    easyeffects.enable = true; # Audio effects for PipeWire.

    # Clipboard Management.
    cliphist.enable = true; # Clipboard history manager.

    # AI/ML Services.
    ollama = {
      enable = true;
      # Architecture-specific acceleration
      acceleration = ollamaAcceleration; # ROCm on x86_64, CPU on ARM64
    };
  };
}