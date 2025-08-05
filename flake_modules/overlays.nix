# Architecture-aware overlays
system: [
  # Custom packages overlay
  (final: prev: {
    # Rose Pine GTK theme
    rose-pine-gtk-theme-full = prev.callPackage ../overlays/rose-pine-gtk-theme-full.nix { };

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