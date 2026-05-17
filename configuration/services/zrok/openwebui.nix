{ pkgs, ... }:
{
  systemd.services.zrok-share-openwebui = {
    description = "zrok share: openwebui (o6sxldv1hn9o)";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.zrok}/bin/zrok share reserved o6sxldv1hn9o";
      Restart = "on-failure";
      RestartSec = "10";
      User = "popcat19";
      Group = "users";
    };
  };
}
