{
  system,
  pkgs,
  ...
}: let
  isX86_64 = system == "x86_64-linux";
  # Note: ROCm acceleration currently disabled due to upstream nixpkgs issue with rocmPackages.stdenv
  # TODO: Re-enable ROCm when upstream issue is resolved
  ollamaAcceleration = null; # CPU fallback for now
in {
  # Generative/AI related packages and services
  # Note: ollama package is managed by the service below
  
  services = {
    # AI/ML Services
    ollama = {
      enable = true;
      acceleration = ollamaAcceleration; # Using CPU fallback due to ROCm stdenv issue
    };
  };
  home.packages = [ pkgs.voicevox ];
}
