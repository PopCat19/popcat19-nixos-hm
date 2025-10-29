#!/usr/bin/env bash

# Helper script to get SSH keys for agenix secrets configuration

set -euo pipefail

echo "🔑 Getting SSH keys for agenix secrets configuration..."
echo ""

# Get user SSH public key
echo "📤 Your SSH public key:"
if [ -f "$HOME/.ssh/id_ed25519.pub" ]; then
    echo "popcat19 = \"$(cat "$HOME/.ssh/id_ed25519.pub")\";"
elif [ -f "$HOME/.ssh/id_rsa.pub" ]; then
    echo "popcat19 = \"$(cat "$HOME/.ssh/id_rsa.pub")\";"
else
    echo "❌ No SSH public key found. Please generate one first:"
    echo "   ssh-keygen -t ed25519 -C \"your-email@example.com\""
    exit 1
fi

echo ""

# Get host SSH public key
echo "🖥️  nixos0 host SSH public key:"
if [ -f "/etc/ssh/ssh_host_ed25519_key.pub" ]; then
    echo "nixos0 = \"$(sudo cat /etc/ssh/ssh_host_ed25519_key.pub)\";"
elif [ -f "/etc/ssh/ssh_host_rsa_key.pub" ]; then
    echo "nixos0 = \"$(sudo cat /etc/ssh/ssh_host_rsa_key.pub)\";"
else
    echo "❌ No host SSH key found. This is unusual for a NixOS system."
    echo "   You may need to regenerate SSH host keys:"
    echo "   sudo ssh-keygen -A"
fi

echo ""
echo "✅ Copy these values into hosts/nixos0/secrets/secrets.nix"
echo ""
echo "📝 Example secrets.nix should look like:"
echo "let"
echo "  popcat19 = \"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI...\";"
echo "  nixos0 = \"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI...\";"
echo "  allUsers = [ popcat19 ];"
echo "  allSystems = [ nixos0 ];"
echo "in"
echo "{"
echo "  \"github-runner/shimboot.token.age\".publicKeys = allUsers ++ allSystems;"
echo "  \"github-runner/nixos-config.token.age\".publicKeys = allUsers ++ allSystems;"
echo "}"