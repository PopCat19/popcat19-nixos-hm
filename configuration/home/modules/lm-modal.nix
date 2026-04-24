# lm-modal.nix
#
# Purpose: Configure lm-modal Wayland LLM overlay
#
# This module:
# - Installs the lm-modal binary from flake input
# - Configures the API endpoint
# - Adds keybind for Hyprland

{ config, lib, inputs, hostPlatform, ... }:

let
  cfg = config.services.lm-modal;
  lm-modal-pkg = inputs.lm-modal.packages.${hostPlatform}.default;
in
{
  options.services.lm-modal = with lib; {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to enable lm-modal Wayland LLM overlay";
    };

    endpoint = mkOption {
      type = types.str;
      default = "http://localhost:8088";
      example = "http://localhost:11434/v1";
      description = "OpenAI-compatible API endpoint";
    };

    model = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "llama3";
      description = "Model name (null uses endpoint default)";
    };

    timeout = mkOption {
      type = types.int;
      default = 120;
      description = "Request timeout in seconds";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ lm-modal-pkg ];

    xdg.configFile."lm-modal/config.toml".text = ''
      endpoint = "${cfg.endpoint}"
      ${lib.optionalString (cfg.model != null) "model = \"${cfg.model}\""}
      timeout = ${toString cfg.timeout}
    '';

    # Add Hyprland keybind
    wayland.windowManager.hyprland.settings.bind = [
      "SUPER, P, exec, lm-modal"
    ];
  };
}