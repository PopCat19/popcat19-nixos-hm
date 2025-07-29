{ pkgs, ... }:

{
  # **USERS & TMPFILES CONFIGURATION**
  # Defines user accounts, groups, and temporary file rules.
  
  # **USER ACCOUNT**
  users.users.popcat19 = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "video"
      "audio"
      "networkmanager"
      "i2c"
      "input"
      "libvirtd"
    ];
    shell = pkgs.fish;
  };

  # **TMPFILES RULES**
  systemd.tmpfiles.rules = [
    "d /home/popcat19            0755 popcat19 users -"
    "d /home/popcat19/Videos     0755 popcat19 users -"
    "d /home/popcat19/Music      0755 popcat19 users -"
  ];
}