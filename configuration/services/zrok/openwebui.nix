{ pkgs, ... }:
{
  systemd.services.zrok-share-openwebui = {
    description = "zrok share: openwebui (o6sxldv1hn9o)";
    after = [ "network-online.target" "open-webui.service" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.zrok}/bin/zrok share reserved o6sxldv1hn9o --headless --override-endpoint=http://127.0.0.1:3000";
      Restart = "on-failure";
      RestartSec = "10";
      User = "popcat19";
      Group = "users";
    };
  };
}
