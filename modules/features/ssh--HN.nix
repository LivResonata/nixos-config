{ ... }:

{
  flake.homeModules.ssh =
    { ... }:
    {
      services.ssh-agent.enable = true;

      programs.ssh = {
        enable = true;
        enableDefaultConfig = false; # Eval warn: Will be removed in the future.

        settings = {
          "github.com" = {
            HostName = "github.com";
            IdentityFile = "~/.ssh/id_gitAuth";
            IdentitiesOnly = "yes";
          };

          "*" = {
            # programs.ssh.enableDefaultConfig entries before option removal
            ForwardAgent = false;
            AddKeysToAgent = "no";
            Compression = false;
            ServerAliveInterval = 0;
            ServerAliveCountMax = 3;
            HashKnownHosts = false;
            UserKnownHostsFile = "~/.ssh/known_hosts";
            ControlMaster = "no";
            ControlPath = "~/.ssh/master-%r@%n:%p";
            ControlPersist = "no";
          };
        };
      };
    };

  flake.nixosModules.ssh =
    { ... }:
    {
      services.openssh = {
        enable = true;
        openFirewall = true;

        settings = {
          PasswordAuthentication = true;
          KbdInteractiveAuthentication = false;
          PermitRootLogin = "no";
          AllowUsers = [ "livresonata" ];
        };
      };
    };
}
