# System-level Mullvad VPN module
{ config, pkgs, lib, ... }:

{
  # Enable Mullvad VPN service (daemon)
  services.mullvad-vpn = {
    enable = true;

    # Use the default package from nixpkgs; override here if you pin a custom version
    # package = pkgs.mullvad-vpn;

    # Whether to wrap commands to bypass the VPN. Keep disabled by default for privacy.
    # See `nixos-options services.mullvad-vpn.enableExcludeWrapper`
    enableExcludeWrapper = lib.mkDefault false;
  };

  # Install Mullvad VPN GUI for controlling connections
  environment.systemPackages = [
    pkgs.mullvad-vpn
  ];

  # Ensure Mullvad daemon is up and auto-connect is enabled silently on boot.
  # This keeps VPN active in the background without popping up a GUI.
  systemd.services.mullvad-autoconnect = {
    description = "Ensure Mullvad auto-connect is enabled";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" "mullvad-daemon.service" ];
    # Add Wants to satisfy ordering constraints and remove the evaluation warning
    wants = [ "network-online.target" ];
    requires = [ "mullvad-daemon.service" ];
    serviceConfig = {
      Type = "oneshot";
      # Idempotent; will just set the preference each boot and exit silently
      ExecStart = "${pkgs.mullvad-vpn}/bin/mullvad auto-connect set on";
    };
  };

  # If you rely on NetworkManager, keep it enabled elsewhere as usual.
  # Mullvad integrates fine with NM. No special OpenVPN/WireGuard toggles needed;
  # Mullvad handles that internally via its daemon.
  #
  # Example (do not force here to avoid changing your networking module decisions):
  # networking.networkmanager.enable = lib.mkDefault true;

  # Firewall/Killswitch:
  # Mullvad's daemon configures firewall rules at runtime. If you want a strict
  # system-level killswitch, consider adding explicit nftables/iptables rules or
  # Mullvad's `block_when_disconnected` via GUI/cli. Not enforced here to keep the
  # module minimally invasive.
}