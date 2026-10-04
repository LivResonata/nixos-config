{ inputs, ... }:

{
  # Some parts may be moved to a modular configuration, but it is not planned as of yet.
  # TODO: Evaluate and move any code that is better suited to be modular.

  flake.nixosModules.flosNetworking =
    { config, ... }:
    let
      sensitivesSecretsPath = toString inputs.sensitivesSecrets;
      sensitivesSecretsData = builtins.fromJSON (
        builtins.readFile "${sensitivesSecretsPath}/sensitives.json"
      );
    in
    {
      networking = {
        hostName = "flos";
        nftables.enable = true;

        firewall = {
          enable = true;
          allowPing = true;

          # This option has a notable effect on VPN services. Use 'loose' if needed.
          ## Values: "strict" / true, "loose", false
          checkReversePath = "loose";

          # Logging
          ## Disable logs to clean up the journal since I don't
          ## read them anyways. Prevents bad screenshots.
          logRefusedConnections = false;

          # Ports
          # TODO: Perhaps there is a better and cleaner way to declare ports?
          # TODO: Possible redundant ports in the list. Clean up preferred.
          ## mDNS = udp[ 5353 ], tcp[ 5353 ]
          ## Samba (Old) = udp[ 137 138 ], tcp[ 139 ] (insecure)
          ## Samba (Active Dir) = udp[ 445 ], tcp[ 445 ]
          ## Scrcpy tcp[ 5037 ]
          ## Seanime = udp[ 43211 ], tcp[ 43211 ]
          ## Virt-manager NAT = udp[ 53 67 ]
          ## OpenVPN = udp[ 80 51820 4569 1194 5060 ], tcp=[ 443 7770 8443 ]
          ## WireGuard = udp[ 443 88 1224 51820 500 4500 ], tcp[ 443 ]
          ## OpenVPN and WireGuard matching duplicates: udp[ 51820 ], tcp[ 443 ]

          allowedUDPPorts = [
            5353
            137
            138
            445
            43211
            53
            67

            80
            51820
            4569
            1194
            5060
            443
            88
            1224
            500
            4500
            # Dupe: 51820
          ];

          allowedTCPPorts = [
            5353
            445
            5037
            43211

            443
            7770
            8443
            # Dupe: 443
          ];

          # For use with nftables only
          ## extraInputRules, filterForward, extraForwardRules
          extraInputRules =
            sensitivesSecretsData.networking.${config.networking.hostName}.firewall.extraInputRules;

          # TODO: Add conditionals to rules if services or programs are enabled or move them to '/modules/features'.
          filterForward = true;
          extraForwardRules = ''
            iifname "virbr0" accept
            oifname "virbr0" accept

            iifname "docker0" accept
            oifname "docker0" accept

            iifname "br-*" accept
            oifname "br-*" accept

            iifname "veth*" accept
            oifname "veth*" accept

            iifname "waydroid0" accept
            oifname "waydroid0" accept
          '';
        };
      };
    };
}
