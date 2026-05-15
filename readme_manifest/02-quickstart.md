## Quick start

```bash
# Clone and build for current host
git clone <repo-url> && cd popcat19-nixos-hm
sudo nixos-rebuild switch --flake .

# Build for specific host
sudo nixos-rebuild switch --flake .#popcat19-nixos0

# Update inputs
nix flake update
```
