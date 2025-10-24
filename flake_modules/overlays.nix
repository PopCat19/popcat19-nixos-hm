# Architecture-aware overlays
system: [
  # Custom packages overlay

  # Import overlays
  # Fix fcitx5-qt6 build issues
  (import ../overlays/fcitx5-fix.nix)
  # Rosé Pine Kvantum themes (from nixpkgs-unstable recipe)
  (import ../overlays/rose-pine-kvantum.nix)
  # Rosé Pine full GTK theme (Main & Moon variants with icons)
  (import ../overlays/rose-pine-gtk-theme-full.nix)
  # Pin ROCm packages to current version from flake.lock (6.3.3)
  (import ../overlays/rocm-pinned.nix)
]
