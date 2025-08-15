{ pkgs, ... }:

{
  # Tablet configuration
  hardware.opentabletdriver = {
  enable = true;
  daemon.enable = true;
  package = pkgs.opentabletdriver;
  };
}