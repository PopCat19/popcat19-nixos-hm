# zrythm.nix
#
# Purpose: Configure real-time audio scheduling for Zrythm DAW
#
# This module:
# - Enables RTKit for real-time process scheduling
# - Sets user limits for audio group (memlock, rtprio, nofile)
# - Adds configured user to audio group
{ userConfig, ... }:
{
  security.rtkit.enable = true;

  security.pam.loginLimits = [
    {
      domain = "@audio";
      item = "memlock";
      type = "-";
      value = "unlimited";
    }
    {
      domain = "@audio";
      item = "rtprio";
      type = "-";
      value = "95";
    }
    {
      domain = "@audio";
      item = "nofile";
      type = "-";
      value = "524288";
    }
  ];

  users.users.${userConfig.username}.extraGroups = [ "audio" ];
}
