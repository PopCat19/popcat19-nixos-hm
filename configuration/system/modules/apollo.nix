# apollo.nix
#
# Purpose: Configure Apollo game streaming server (Sunshine fork)
#
# This module:
# - Uses apollo-flake for low-latency game streaming
# - Configures systemd user service with required capabilities
# - Sets up firewall ports for streaming connections
# - Enables KMS capture and input device access
{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
let
  cfg = config.services.apollo;

  apolloPackage = inputs.apollo.packages.${pkgs.stdenv.hostPlatform.system}.default;

  generatePorts = port: offsets: map (offset: port + offset) offsets;
  defaultPort = 47989;

  appsFormat = pkgs.formats.json { };
  settingsFormat = pkgs.formats.keyValue { };

  appsFile = appsFormat.generate "apps.json" cfg.applications;
  configFile = settingsFormat.generate "sunshine.conf" cfg.settings;
in
{
  options.services.apollo = {
    enable = lib.mkEnableOption "Apollo game streaming server";

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

    settings = lib.mkOption {
      default = { };
      description = "Configuration settings for Apollo";
      example = lib.literalExpression ''
        {
          sunshine_name = "NixOS Gaming";
          min_log_level = "info";
        }
      '';
      type = lib.types.submodule (_settingsSubmodule: {
        freeformType = settingsFormat.type;
        options.port = lib.mkOption {
          type = lib.types.port;
          default = defaultPort;
          description = "Base port for Apollo";
        };
      });
    };

    applications = lib.mkOption {
      default = { };
      description = "Application configurations for Apollo";
      example = lib.literalExpression ''
        {
          env = {
            PATH = "$(PATH):$(HOME)/.local/bin";
          };
          apps = [
            {
              name = "Steam Big Picture";
              detached = [ "steam steam://open/bigpicture" ];
              image-path = "steam.png";
            }
          ];
        }
      '';
      type = lib.types.submodule {
        options = {
          env = lib.mkOption {
            default = { };
            description = "Global environment variables for applications";
            type = lib.types.attrsOf lib.types.str;
          };
          apps = lib.mkOption {
            default = [ ];
            description = "List of applications to expose to Moonlight";
            type = lib.types.listOf lib.types.attrs;
          };
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.apollo.settings.file_apps = lib.mkIf (cfg.applications.apps != [ ]) "${appsFile}";

    environment.systemPackages = [ apolloPackage ];

    boot.kernelModules = [ "uinput" ];

    services.udev.packages = [ apolloPackage ];

    services.avahi = {
      enable = lib.mkDefault true;
      publish = {
        enable = lib.mkDefault true;
        userServices = lib.mkDefault true;
      };
    };

    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = generatePorts cfg.settings.port [
        (-5)
        0
        1
        21
      ];
      allowedUDPPorts = generatePorts cfg.settings.port [
        9
        10
        11
        13
        21
      ];
    };

    security.wrappers.apollo = lib.mkIf cfg.capSysAdmin {
      owner = "root";
      group = "root";
      capabilities = "cap_sys_admin+p";
      source = "${apolloPackage}/bin/sunshine";
    };

    systemd.user.services.apollo = {
      description = "Apollo Game Streaming Server";

      wantedBy = lib.mkIf cfg.autoStart [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];

      startLimitIntervalSec = 500;
      startLimitBurst = 5;

      environment.PATH = lib.mkForce null;

      serviceConfig = {
        ExecStart = lib.utils.escapeSystemdExecArgs (
          [
            (
              if cfg.capSysAdmin then "${config.security.wrapperDir}/apollo" else "${apolloPackage}/bin/sunshine"
            )
          ]
          ++ lib.optionals (
            cfg.applications.apps != [ ]
            || (builtins.length (builtins.attrNames cfg.settings) > 1 || cfg.settings.port != defaultPort)
          ) [ "${configFile}" ]
        );
        Restart = "on-failure";
        RestartSec = "5s";
      };
    };
  };
}
