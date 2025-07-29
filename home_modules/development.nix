{ pkgs, ... }:

{
  home.packages = with pkgs; [
    jdk
    nodejs
    yarn-berry
    rustup
  ];
}