# llama-cpp.nix
#
# Purpose: Configures llama.cpp inference server.
#
# This module:
# - Installs llama-cpp, with ROCm support on AMD GPU hosts
# - Runs llama-server as a user service on port 8088, bound to 0.0.0.0
# - Stores models in ~/.local/share/llama-cpp/models
{
  pkgs,
  userConfig,
  ...
}:
let
  rocm = userConfig.gaming.enableROCm or false;
  llamaPkg = if rocm then pkgs.llama-cpp.override { rocmSupport = true; } else pkgs.llama-cpp;
in
{
  home.packages = [ llamaPkg ];

  systemd.user.services.llama-cpp = {
    Unit = {
      Description = "llama.cpp inference server";
      After = [ "network.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${llamaPkg}/bin/llama-server --host 0.0.0.0 --port 8088";
      Restart = "on-failure";
      RestartSec = "5";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
