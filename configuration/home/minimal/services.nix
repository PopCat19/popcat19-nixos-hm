_: {
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

    # AI/ML Services moved to ../../home_modules/generative.nix
  };
}
