{ ... }:

{
  flake.nixosModules.samba =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      networking.firewall = {
        allowedUDPPorts = [ 445 ]; # Microsoft-DS SMB file sharing (UDP)
        allowedTCPPorts = [ 445 ]; # Microsoft-DS Active Directory, Windows shares (TCP)
      };

      services.samba = {
        enable = true;
        package = pkgs.samba;

        /*
          WARN: NetBIOS ports are legacy and may be insecure: udp[ 137 138 ], tcp[ 139].

          See: https://wiki.centos.org/HowTos(2f)SetUpSamba.html
        */
        # Opens udp[ 137 138 ], tcp[ 139 445 ].
        openFirewall = lib.mkForce false;

        settings = {
          global = {
            "server string" = "${config.networking.hostName}";
            "netbios name" = "${config.networking.hostName}";
            "security" = "user";
            # note: localhost is the ipv6 localhost ::1
            "hosts allow" = "192.168.0. 192.168.1. 127.0.0.1 localhost";
            "guest account" = "guest";
            "map to guest" = "bad user";
          };

          public = {
            "path" = "/srv/Public";
            "browseable" = "yes";
            "writable" = "no";
            "guest ok" = "yes";
            "only guest" = "yes";
            "force user" = "guest";
            "force group" = "public";
          };
        };
      };

      users = {
        users.guest = {
          isNormalUser = true;
          password = "guest";
          createHome = false;
          group = "public";
          extraGroups = [ "users" ];
          shell = pkgs.shadow; # Disables login.
          useDefaultShell = false;
        };

        groups = {
          # Access to `/srv/Public` network share folder
          public = {
            members = [
              "guest"
            ];
          };
        };
      };
    };
}
