{
  pkgs,
  ...
}: {
  # Generative/AI related packages
  # Note: ollama service is now managed by ollama-rocm.nix module
  
  home.packages = [ pkgs.voicevox ];
}
