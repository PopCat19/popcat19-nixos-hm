# llm-note.md

We don't use home-manager related commands as it's managed by nixos.

Useful fish functions from `./home-modules/fish.nix`.

Note that no configurations will update without rebuilding nixos on the current host. If you're working on configurations for another host, ask user to rebuild the said host before proceeding.

Always `git add .` when you create new, untracked files/directories to update git tree for flake evaluation.
|
`nixos-commit-rebuild-push` already does this among other git functions, run this to commit (adhering commit rules), rebuild, and push:
```
nixos-commit-rebuild-push "<[feat|fix|refactor|docs]:4/5-word-summary>"
```

To just rebuild without git (warn: won't git add . for flakes):
```
nixos-rebuild-basic
```
|
If you receive ENOENT flake errors, check `git status` for uncommited changes and then `git add .` if untracked.

To test a machine configuration:
```
nixos-rebuild dry-run --flake .#<hostname>
```

To check flakes/configurations:
```
nix flake check
```

To query nixpkgs:
```
nix search nixpkgs <package>
```

To check hyprland errors:
```
hyprctl configerrors
```

Other hyprctl commands can be discovered via:
```
hyprctl -h
```

To check the current system:
```
whoami && hostname && fastfetch
```

To check recent logs for current system:
```
journalctl | tail -80 && sudo dmesg | tail -40
```

Note that you can `-h`, `--help`, `tldr`, and `man` any command to discover possible args.