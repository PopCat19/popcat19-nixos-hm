#!/usr/bin/env bash
sudo http_proxy="http://192.168.49.1:8282" \
	https_proxy="http://192.168.49.1:8282" \
	all_proxy="socks5h://192.168.49.1:1080" \
	nixos-rebuild switch --flake . --option sandbox false
