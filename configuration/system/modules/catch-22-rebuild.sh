#!/usr/bin/env bash
# catch-22-rebuild.sh
#
# Purpose: Rebuild NixOS through proxy to bypass sandbox restrictions
#
# This script:
# - Runs nixos-rebuild with proxy settings and sandbox disabled
sudo http_proxy="http://192.168.49.1:8282" \
	https_proxy="http://192.168.49.1:8282" \
	all_proxy="socks5h://192.168.49.1:1080" \
	nixos-rebuild switch --flake . --option sandbox false
