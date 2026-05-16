# excalidraw.nix
#
# Purpose: Declare Excalidraw collaborative whiteboard via OCI container
#
# This module:
# - Declares the excalidraw/excalidraw:latest container
# - Binds to localhost:8082 in reserved self-host port range
{ config, lib, ... }:

let
  cfg = config.services.excalidraw;
in
{
  options.services.excalidraw = with lib; {
    enable = mkEnableOption "Excalidraw collaborative whiteboard";
    port = mkOption {
      type = types.port;
      default = 8082;
      description = "Host port to bind Excalidraw to (localhost only)";
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation.oci-containers.containers.excalidraw = {
      image = "excalidraw/excalidraw:latest";
      ports = [ "127.0.0.1:${toString cfg.port}:80" ];
      autoStart = true;
    };
  };
}
