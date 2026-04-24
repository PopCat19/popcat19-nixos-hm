# lm-modal.nix
#
# Purpose: Configure lm-modal Wayland LLM overlay
#
# This module:
# - Enables lm-modal via Home Manager
# - Configures endpoint for pi-gateway
# - Adds keybind for Hyprland

{ config, lib, inputs, ... }:

let
  cfg = config.services.lm-modal;
in
{
  imports = [ inputs.lm-modal.homeManagerModules.default ];

  options.services.lm-modal = with lib; {
    enable = mkEnableOption "lm-modal Wayland LLM overlay";

    endpoint = mkOption {
      type = types.str;
      default = "http://localhost:8088";
      description = "OpenAI-compatible API endpoint";
    };

    model = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Model name (null uses endpoint default)";
    };

    keybind = mkOption {
      type = types.str;
      default = "SUPER, P";
      description = "Hyprland keybind to launch lm-modal";
    };
  };

  config = lib.mkIf cfg.enable {
    services.lm-modal = {
      inherit (cfg) enable endpoint model;
    };

    wayland.windowManager.hyprland.settings.bind = [
      "${cfg.keybind}, exec, lm-modal"
    ];
  };
}