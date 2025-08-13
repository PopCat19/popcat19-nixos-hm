{ pkgs, ... }:

{
  # Game streaming client packages
  
  home.packages = with pkgs; [
    moonlight-qt
  ];
}