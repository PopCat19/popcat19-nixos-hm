# Context

- `default.nix`: Aggregates all library functions (mkHost, mkHome, helpers)
- `helpers.nix`: Path existence checks, attrset merging, directory filtering
- `mk-host.nix`: Auto-discovers hosts from `configuration/hosts/`, builds nixosConfigurations
- `mk-home.nix`: Wraps home-manager config with standard defaults and user/platform config
