# llm-note.md

We don't use home-manager related commands as it's managed by nixos.

Useful fish functions from `./home-modules/fish.nix`.

Note that no configurations will date without rebuilding nixos on current host.

Always `git add .` when you create new, untracked files/directories to update git tree for flake evaluation.
|
`nixos-commit-rebuild-push` already does this among other git functions, run that instead.

To just rebuild without adding nor commiting, run:
```
nixos-rebuild-basic
```

Preferably for nixos flakes, to commit, rebuild, and push, run:
```
nixos-commit-rebuild-push '<4/5-word-commit>'
```

To test a machine configuration, run:
```
nixos-rebuild dry-run --flake .#<hostname>
```

To check flakes/configurations, run:
```
nix flake check
```

To query nixpkgs, run:
```
nix search nixpkgs <package>
```

To check hyprland errors, run:
```
hyprctl configerrors
```

To check the current system logs, run:
```
whoami && hostname && journalctl | tail -80 && sudo dmesg | tail -40
```

Note that you can `-h`, `--help`, `tldr`, and `man` a command to discover possible args.