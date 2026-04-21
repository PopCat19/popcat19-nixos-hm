#!/usr/bin/env bash
# Purpose: Toggle between split layout orientations
current=$(hyprctl getoption general:layout | sed -n 's/.*: //p')
case "$current" in
"Dwindle")
	hyprctl keyword general:layout "Dwindle"
	hyprctl keyword general:split_ratio 0.35
	;;
*)
	hyprctl keyword general:layout "Dwindle"
	hyprctl keyword general:split_ratio 0.5
	;;
esac
