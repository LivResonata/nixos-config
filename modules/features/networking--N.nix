{ inputs, ... }:

{
  flake.nixosModules.networking =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      # For Options
      cfg = config.networking;
      dnsServiceList = [
        "dnscrypt-proxy"
        "systemd-resolved"
      ];

      # Sensitives and Secrets
      sensitivesSecretsPath = toString inputs.sensitivesSecrets;
      sensitivesSecretsData = builtins.fromJSON (
        builtins.readFile "${sensitivesSecretsPath}/sensitives.json"
      );
    in
    {
      options.networking = {
        dnsService = lib.mkOption {
          type = lib.types.str;
          default = "dnscrypt-proxy";
          example = "systemd-resolved";
          description = ''
            Selects which DNS service is used for resolution.

            - `dnscrypt-proxy`: handles DNS resolution while `systemd-resolved` for mDNS and caching.
            - `systemd-resolved`: uses DNS-over-TLS for resolution alongside mDNS.
          '';

          apply =
            dns:
            let
              invalid = if !(builtins.elem dns dnsServiceList) then [ dns ] else [ ];
            in
            if invalid != [ ] then
              abort "Invalid `dnsService` value: \"${dns}\". Valid options are: ${
                toString (map (c: "\"${c}\"") dnsServiceList)
              }."
            else
              dns;
        };

        protonvpn.enable = lib.mkEnableOption null // {
          default = false;
          example = true;
          description = ''
            Installs ProtonVPN and recommended packages.

            Does not support DNS-over-TLS. Disable or tweak the relevant option in your DNS service.
            Recommend to use `networking.dnsService = "dnscrypt-proxy"` as its sensitiveSecrets stamp doesn't use DoT.
          '';

          apply =
            vpn:
            if cfg.dnsService == "system-resolved" && config.services.resolved.settings.Resolve.DNSOverTLS then
              abort "`systemd-resolved` has DNS-over-TLS enabled. ProtonVPN does not support it and will malfunction."
            else
              vpn;
        };
      };

      config = {
        environment.systemPackages =
          with pkgs;
          [ ]
          ++ lib.optionals cfg.protonvpn.enable [
            # VPN
            proton-vpn

            # Backends
            openvpn
            wireguard-tools
            update-resolv-conf
          ];

        networking = {
          networkmanager = {
            enable = true;
            dns = lib.mkDefault "none";

            plugins =
              with pkgs;
              [ ]
              ++ lib.optionals cfg.protonvpn.enable [
                networkmanager-openvpn
              ];

            settings = {
              main = {
                systemd-resolved = true;
              };
            };
          };
        };

        services = {
          dnscrypt-proxy = {
            enable = if cfg.dnsService == "dnscrypt-proxy" then true else false;

            # For options, see: https://github.com/DNSCrypt/dnscrypt-proxy/blob/master/dnscrypt-proxy/example-dnscrypt-proxy.toml
            settings = {
              cache = false; # Let systemd-resolved handle it.
              ignore_system_dns = true;

              listen_addresses = [
                "127.0.0.1:54"
                "[::1]:54"
              ];

              # DNS Servers
              server_names = [
                sensitivesSecretsData.networking.${config.networking.hostName}.dns.dnscrypt-proxy.server_names
              ];
              static.${
                sensitivesSecretsData.networking.${config.networking.hostName}.dns.dnscrypt-proxy.static_dns
              } =
                {
                  stamp = sensitivesSecretsData.networking.${config.networking.hostName}.dns.dnscrypt-proxy.stamp;
                };

              # DNS Requirement Filters
              require_nolog = false;
              require_dnssec = false;
              require_nofilter = false;

              # IPv6 Support
              # Use servers reachable over IPv6. Do not enable if IPv6 connectivity is not available.
              ipv6_servers = true;
              block_ipv6 = false;

              # HTTP/3 or DNS-over-QUIC Support
              http3 = false;

              # Monitoring UI
              monitoring_ui = {
                enabled = true;
                privacy_level = 2;
                listen_address = "127.0.0.1:8082";
                enable_query_log = false;

                username = "";
                password = "";
              };
            };
          };

          resolved = {
            enable = true;

            settings.Resolve = lib.mkMerge [
              {
                # For options, see: https://www.freedesktop.org/software/systemd/man/latest/resolved.conf.html
                #                   https://search.nixos.org/options?channel=unstable&query=services.resolved&type=options

                Cache = true;
                LLMNR = true;
                DNSSEC = "allow-downgrade"; # Values: `true, `"allow-downgrade"`, `false`.
                FallbackDNS = "";
                MulticastDNS = true;
                DNSStubListener = true; # Values: `true` (both tcp and udp), `"tcp"`, `"udp"`, false; listens to 127.0.0.53/54:53.
              }

              (lib.mkIf (cfg.dnsService == "dnscrypt-proxy") {
                DNS = "127.0.0.1:54 [::1]:54";
                DNSOverTLS = false; # Values: `true`, `"opportunistic", or `false`.
                CacheFromLocalhost = true; # Cache localhost DNS forwarding to DNSCrypt Proxy which has no caching enabled.
              })

              (lib.mkIf (cfg.dnsService == "systemd-resolved") {
                DNS = sensitivesSecretsData.networking.${config.networking.hostName}.dns.systemd-resolved;
                DNSOverTLS = true; # Values: `true`, `"opportunistic", or `false`.
                CacheFromLocalhost = false;
              })
            ];
          };
        };

        systemd.services.dnscrypt-proxy.serviceConfig.StateDirectory = "dnscrypt-proxy";
      };
    };
}
