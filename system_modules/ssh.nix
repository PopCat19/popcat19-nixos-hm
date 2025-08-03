{ userConfig, ... }:

{
  # **SSH SERVER CONFIGURATION**
  # Configures SSH server for all hosts
  
  services.openssh = {
    enable = true;
    settings = {
      # Security settings
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
      
      # Performance settings
      MaxSessions = 10;
      MaxStartups = "10:30:60";
      
      # Additional security hardening
      X11Forwarding = false;
      PrintMotd = false;
      PrintLastLog = true;
      TCPKeepAlive = true;
      ClientAliveInterval = 300;
      ClientAliveCountMax = 3;
      
      # Allow agent forwarding for convenience
      AllowAgentForwarding = true;
    };
    
    # Ensure proper environment for SSH sessions
    extraConfig = ''
      SetEnv PATH=/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
    '';
  };
  
  # User configuration for SSH keys
  users.users.${userConfig.user.username} = {
    openssh.authorizedKeys.keys = [
      # Default SSH key - can be overridden per host
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFvtrt7vEbXSyP8xuOfsfNGgC99Y98s1fmBIp3eZP4zx popcat19@nixos"
    ];
  };
}