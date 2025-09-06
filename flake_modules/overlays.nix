# Architecture-aware overlays
system: [
  # Custom packages overlay
  (final: prev: {
    # Hyprshade 4.0.0 - Hyprland shade configuration tool
    # Updates shaders to GLES version 3.0, can auto-configure on schedule
    hyprshade = prev.python3Packages.callPackage ../overlays/hyprshade.nix {
      hyprland = prev.hyprland;
    };
  })

  # Import overlays
  (import ../overlays/zrok.nix)
  (import ../overlays/quickemu.nix)
]