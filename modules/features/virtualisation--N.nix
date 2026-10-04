{ ... }:

{
  flake.nixosModules.virtualisation =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.virtualisation.features;
    in
    {
      options.virtualisation.features = {
        waydroid.enable = lib.mkEnableOption null // {
          default = true;
          example = false;
          description = "Enables Waydroid android environment with Waydroid Helper package.";
        };
      };

      config = {
        environment.systemPackages =
          with pkgs;
          [ ] ++ lib.optionals cfg.waydroid.enable [ waydroid-helper ];

        programs = {
          # Disabled
          virt-manager.enable = lib.mkDefault false;
        };

        networking.firewall = lib.mkMerge [
          {
            /*
              NOTE: `filterForward` requires `networking.nftables.enable = true`.

              # Interfaces
              These are set to be always merged, without relevant conditions and options.

              - Docker
              `docker0`, `br-*` (by containers), `veth*` (by containers).
            */

            filterForward = true;
            extraForwardRules = ''
              iifname "br-*" accept
              oifname "br-*" accept

              iifname "docker0" accept
              oifname "docker0" accept

              iifname "veth*" accept
              oifname "veth*" accept
            '';
          }

          (lib.mkIf config.programs.virt-manager.enable {
            ## Virt-manager NAT
            allowedUDPPorts = [
              53
              67
            ];

            extraForwardRules = ''
              iifname "virbr0" accept
              oifname "virbr0" accept
            '';
          })

          (lib.mkIf cfg.waydroid.enable {
            extraForwardRules = ''
              iifname "waydroid0" accept
              oifname "waydroid0" accept
            '';
          })
        ];

        virtualisation = lib.mkMerge [
          {
            # Docker
            docker = {
              enable = lib.mkDefault true;

              rootless = {
                enable = false;
                setSocketVariable = true;
              };
            };
          }

          (lib.mkIf cfg.waydroid.enable {
            waydroid.enable = if cfg.waydroid.enable then true else false;
          })

          # For `programs.virt-manager`.
          (lib.mkIf config.programs.virt-manager.enable {
            libvirtd.enable = true;
            spiceUSBRedirection.enable = true;
          })
        ];
      };
    };
}
