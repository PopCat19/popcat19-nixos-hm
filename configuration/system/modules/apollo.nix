# apollo.nix
#
# Purpose: Configure Apollo game streaming server (Sunshine fork)
#
# This module:
# - Builds Apollo from source for low-latency game streaming
# - Configures systemd user service with required capabilities
# - Sets up firewall ports for streaming connections
# - Enables KMS capture and input device access
{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.services.apollo;

  ports = {
    webInterface = 47990;
    webUi = 47989;
    rtsp = 48010;
    streamRangeStart = 47998;
    streamRangeEnd = 48000;
  };
in
{
  options.services.apollo = {
    enable = lib.mkEnableOption "Apollo game streaming server";

    package = lib.mkPackageOption pkgs "sunshine" {
      example = "pkgs.sunshine.override { cudaSupport = true; }";
    };

    autoStart = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to start Apollo automatically on login";
    };

    capSysAdmin = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Add CAP_SYS_ADMIN capability to Apollo for KMS capture";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Open firewall ports for Apollo streaming";
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = config.users.users.${config.mainUser or "root"}.name or "root";
      example = "alice";
      description = "User to run Apollo as";
    };

    settings = lib.mkOption {
      type = lib.types.attrsOf lib.types.anything;
      default = { };
      example = lib.literalExpression ''
        {
          sunshine_name = "NixOS Gaming";
          min_log_level = "info";
        }
      '';
      description = "Configuration settings for Apollo";
    };

    applications = lib.mkOption {
      type = lib.types.attrsOf lib.types.anything;
      default = { };
      example = lib.literalExpression ''
        {
          apps = [
            {
              name = "Steam Big Picture";
              detached = [ "steam steam://open/bigpicture" ];
              image-path = "steam.png";
            }
          ];
        }
      '';
      description = "Application configurations for Apollo";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    security.wrappers.sunshine = lib.mkIf cfg.capSysAdmin {
      owner = "root";
      group = "root";
      capabilities = "cap_sys_admin+p";
      source = "${cfg.package}/bin/sunshine";
    };

    services.udev.extraRules = ''
      KERNEL=="uinput", MODE="0660", GROUP="input", OPTIONS+="static_node=uinput"
      KERNEL=="event*", SUBSYSTEM=="input", MODE="0660", GROUP="input"
    '';

    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [
        ports.webInterface
        ports.webUi
        ports.rtsp
      ];
      allowedUDPPortRanges = [
        {
          from = ports.streamRangeStart;
          to = ports.streamRangeEnd;
        }
      ];
    };

    systemd.user.services.apollo = {
      description = "Apollo Game Streaming Server";
      wantedBy = lib.mkIf cfg.autoStart [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        ExecStart = "${cfg.package}/bin/sunshine";
        Restart = "on-failure";
        RestartSec = "5s";
      };
      environment = {
        DISPLAY = ":0";
      };
    };

    users.users.${cfg.user}.extraGroups = [
      "input"
      "video"
    ];
  };
}
