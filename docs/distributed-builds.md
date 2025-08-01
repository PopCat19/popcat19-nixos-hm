# Distributed Builds Setup

This document explains how to set up distributed builds between `popcat19-nixos0` (build server) and `popcat19-surface0` (client).

## Overview

- **nixos0** (192.168.50.172): R5 5500 (6c/12t), 32GB DDR4 - Acts as build server
- **surface0** (192.168.50.219): Surface device - Acts as client, delegates builds to nixos0

## Configuration Files

### Client Side (surface0)
- `system_modules/distributed-builds.nix` - Client configuration for using remote builders
- `hosts/surface/configuration.nix` - Includes distributed builds configuration

### Server Side (nixos0)
- `system_modules/distributed-builds-server.nix` - Server configuration for accepting builds
- `configuration.nix` - Main nixos0 configuration includes server setup

## Setup Steps

### 1. Deploy Configurations

On **surface0** (current machine):
```bash
# Test the surface0 configuration
nixos-rebuild dry-run --flake .#popcat19-surface0

# Apply the surface0 configuration
nixos-commit-rebuild-push "setup distributed builds surface0"
```

On **nixos0** (you'll need to copy this repo there):
```bash
# Test the nixos0 configuration
nixos-rebuild dry-run --flake .#popcat19-nixos0

# Apply the nixos0 configuration
nixos-commit-rebuild-push "setup distributed builds nixos0"
```

### 2. Test SSH Connectivity

From surface0 to nixos0:
```bash
ssh popcat19@192.168.50.172 "hostname && nix --version"
```

### 3. Test Distributed Build

From surface0, test building a simple package using nixos0:
```bash
# This should use nixos0 for building
nix build nixpkgs#hello --builders "ssh://popcat19@192.168.50.172 x86_64-linux"
```

### 4. Build Surface Configuration on nixos0

From surface0, build the surface configuration using nixos0:
```bash
# Build surface0 configuration on nixos0
nixos-rebuild --flake .#popcat19-surface0 --build-host popcat19@192.168.50.172 --target-host localhost switch
```

## Key Features

### Build Machine Configuration
- **maxJobs**: 12 (uses all R5 5500 threads)
- **speedFactor**: 3 (nixos0 is 3x faster than surface0)
- **supportedFeatures**: nixos-test, benchmark, big-parallel, kvm

### Security
- SSH key-based authentication only
- No password authentication
- Restricted to popcat19 user

### Performance Optimizations
- Optimized kernel parameters for build workloads
- Increased file descriptor limits
- Memory management tuning for parallel builds

## Troubleshooting

### SSH Connection Issues
```bash
# Check SSH service on nixos0
ssh popcat19@192.168.50.172 "systemctl status sshd"

# Check firewall
ssh popcat19@192.168.50.172 "sudo iptables -L | grep ssh"
```

### Build Issues
```bash
# Check Nix daemon on nixos0
ssh popcat19@192.168.50.172 "systemctl status nix-daemon"

# Check available builders
nix show-config | grep builders
```

### Network Issues
```bash
# Test connectivity
ping 192.168.50.172

# Check if SSH port is open
nmap -p 22 192.168.50.172
```

## Cross-Compilation vs Distributed Builds

This setup uses **distributed builds** (same architecture, different machines) rather than cross-compilation (different architectures). Both machines are x86_64-linux, so we're leveraging the more powerful nixos0 machine to build packages faster.

For true cross-compilation (e.g., building ARM packages on x86_64), you would use:
```bash
nix build nixpkgs#pkgsCross.aarch64-multiplatform.hello