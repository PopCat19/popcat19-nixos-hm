# NixOS Config Commands

## Core Commands

**Add Package**
```
fish -c "nixpkg add <package> -d -m 'add <package>'"
```

**Remove Package** 
```
fish -c "nixpkg remove <package> -d -m 'remove <package>'"
```

**Apply Config**
```
fish -c "nixos-apply-config -d -m 'update config'"
```

**Search Package**
```
nix search nixpkgs <package>
```

## Flags
- `-d` - Dry-run test first
- `-m "msg"` - Commit with message
- `-f` - Fast mode (skip checks)

## Examples
```
fish -c "nixpkg add firefox -d -m 'add browser'"
fish -c "nixpkg remove htop -m 'remove tool'"
fish -c "nixos-apply-config -d -m 'manual changes'"
```

## Utils
```
hyprctl configerrors    # Check Hyprland
tree -L 4              # View structure
git status             # Check changes
```
