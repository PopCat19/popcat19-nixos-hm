{ pkgs, ... }:
{
  systemd.services.zrok-share-searxng = {
    description = "zrok share: searxng (7gqoj8ce5mm0)";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.zrok}/bin/zrok share reserved 7gqoj8ce5mm0";
      Restart = "on-failure";
      RestartSec = "10";
      User = "popcat19";
      Group = "users";
    };
  };
}
