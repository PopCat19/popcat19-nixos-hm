# llm-note.md

Useful fish functions from `./home-modules/fish.nix`.

Always `git add .` when you create new, untracked files/directories to update git tree for flake evaluation.

`nixos-commit-rebuild-push` already does this among other git functions, run that instead.

To just rebuild, run:
```
nixos-commit-rebuild-push
```

To commit, rebuild, and push, run:
```
nixos-commit-rebuild-push '<commit>'
```

To query nixpkgs, run:
```
nix search nixpkgs <package>
```

To check hyprland errors, run:
```
hyprctl configerrors
```
