{ pkgs, ... }:
{
  systemd.services.zrok-share-odysseus = {
    description = "zrok share: odysseus (9n0xuaqa3t6m)";
    after = [
      "network-online.target"
      "odysseus.service"
    ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.zrok}/bin/zrok share reserved 9n0xuaqa3t6m --headless";
      Restart = "on-failure";
      RestartSec = "10";
      User = "popcat19";
      Group = "users";
    };
  };
}
