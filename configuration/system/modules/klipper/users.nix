# users.nix
#
# Purpose: System users and groups for the Klipper printer stack
{
  users.users = {
    klipper = {
      isSystemUser = true;
      group = "klipper";
      home = "/home/klipper";
      createHome = true;
    };
    moonraker = {
      isSystemUser = true;
      group = "moonraker";
      extraGroups = [ "klipper" ];
      home = "/home/moonraker";
      createHome = true;
    };
  };

  users.groups = {
    klipper = { };
    moonraker = { };
  };
}
