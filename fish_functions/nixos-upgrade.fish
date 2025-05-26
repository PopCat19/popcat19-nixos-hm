function nixos-upgrade -d "󰚰 Update flake inputs, then 🚀 apply"
  echo "󰚰 Starting NixOS system upgrade (flake update + apply)..."
  if flake-update $argv[2..-1]
    nixos-apply-config $argv[1]
  else
    echo "❌ System upgrade failed during flake update."
    return 1
  end
end
