{ pkgs, ... }: {
  systemd.services.zrok-share-sillytavern = {
    description = "zrok share: sillytavern (5f5icptoebhm)";
    after = [ "network-online.target" "sillytavern.service" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.zrok}/bin/zrok share reserved 5f5icptoebhm";
      Restart = "on-failure";
      RestartSec = "10";
      User = "popcat19";
      Group = "users";
    };
  };
}
