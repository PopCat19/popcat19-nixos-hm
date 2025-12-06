{pkgs, ...}: {
  # Generative/AI related packages
  # Note: ollama service is now managed by ollama.nix module

  home.packages = [pkgs.voicevox];
}
