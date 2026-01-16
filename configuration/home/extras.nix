# Extras Home Configuration
#
# Purpose: Optional modules for gaming, AI/ML, and additional features
# Dependencies: main.nix
# Related: minimal.nix, main.nix
#
# This module:
# - Imports optional home modules
# - Provides gaming, AI/ML, and extended functionality
{...}: {
  imports = [
    ./main.nix
    ./extras/gaming/mangohud.nix
    ./extras/ai-ml/generative.nix
    ./extras/ai-ml/ollama.nix
    ./extras/launchers/vicinae.nix
  ];
}
