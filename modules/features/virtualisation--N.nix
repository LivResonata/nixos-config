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

            # Waydroid
            waydroid.enable = if cfg.waydroid.enable then true else false;
          }

          # Virt-manager
          (lib.mkIf config.programs.virt-manager.enable {
            libvirtd.enable = true;
            spiceUSBRedirection.enable = true;
          })
        ];
      };
    };
}
