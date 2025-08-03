{ ... }:

{
  # **SSH CONFIGURATION**
  # Configures SSH client settings for distributed builds
  
  programs.ssh = {
    enable = true;
    
    # SSH client configuration
    extraConfig = ''
      # Host configuration for distributed builds
      Host 192.168.50.172
        User popcat19
        IdentityFile ~/.ssh/id_ed25519
        StrictHostKeyChecking no
        UserKnownHostsFile /dev/null
        ForwardX11 no
        ForwardX11Trusted no
        Compression yes
        ControlMaster auto
        ControlPath ~/.ssh/master-%r@%h:%p
        ControlPersist 600

      # Host configuration for surface0
      Host 192.168.50.219
        User popcat19
        IdentityFile ~/.ssh/id_ed25519
        StrictHostKeyChecking no
        UserKnownHostsFile /dev/null
        ForwardX11 no
        ForwardX11Trusted no
        Compression yes
        ControlMaster auto
        ControlPath ~/.ssh/master-%r@%h:%p
        ControlPersist 600
    '';
  };
}