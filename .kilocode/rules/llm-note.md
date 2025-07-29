# llm-note.md

Useful fish functions from `./home-modules/fish.nix`.\
Always `git add .` when you create new, untracked files/directories to update git tree for flake evaluation.

**Apply Config (rebuild)**
```
nixos-commit-rebuild-push '<commit>'
```

**Search Package**
```
nix search nixpkgs <package>
```

**Hyprland Debug**
```
hyprctl configerrors
```
