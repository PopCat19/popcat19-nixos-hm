{ pkgs, ... }:

{
  home.packages = with pkgs; [
    jdk
    nodejs_latest
    yarn-berry
    rustup
  ];
}