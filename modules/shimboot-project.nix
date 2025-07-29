{ pkgs, ... }:

{
  home.packages = with pkgs; [
    sunxi-tools
    binwalk
    vboot_reference
    pv
    parted
    squashfsTools
    nixos-install-tools
    nixos-generators
  ];
}