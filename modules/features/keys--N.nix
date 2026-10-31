{ ... }:

{
  flake.nixosModules.keys =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      programs.gnupg = {
        package = pkgs.gnupg;
        dirmngr.enable = true;

        agent = {
          enable = true;
          pinentryPackage = pkgs.pinentry-egui;
          enableSSHSupport = true;

          settings = {
            max-cache-ttl = 1800; # 30 minutes or 1800 seconds.
            default-cache-ttl = 1800;

            max-cache-ttl-ssh = 1800;
            default-cache-ttl-ssh = 1800;
          };
        };
      };

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

      # Disable services that override SSH_AUTH_SOCK environment variable against gpg-agent.
      systemd.user = lib.mkMerge [
        (lib.mkIf config.services.gnome.gnome-keyring.enable {
          sockets.gcr-ssh-agent.enable = lib.mkForce false;
          services.gcr-ssh-agent.enable = lib.mkForce false;
        })

        (lib.mkIf config.services.openssh.enable {
          services.ssh-agent.enable = lib.mkForce false;
        })
      ];

      home-manager.sharedModules = [
        {
          home.sessionVariables = {
            SSH_AUTH_SOCK = "\${XDG_RUNTIME_DIR}/gnupg/S.gpg-agent.ssh";
          };

          programs.ssh = {
            enable = true;
            enableDefaultConfig = false; # NOTE: Eval warn: Will be removed in the future.

            settings = {
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
        }
      ];
    };
}
