{ ... }:

{
  flake.nixosModules.virtualisation =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      environment.systemPackages = with pkgs; [
        waydroid-helper
      ];

      programs = {
        # Disabled
        virt-manager.enable = false;
      };

      virtualisation = lib.mkMerge [
        {
          # Docker
          docker = {
            enable = true;

            rootless = {
              enable = false;
              setSocketVariable = true;
            };
          };

          # Waydroid
          waydroid.enable = true;
        }

        # Virt-manager
        (lib.mkIf config.programs.virt-manager.enable {
          libvirtd.enable = true;
          spiceUSBRedirection.enable = true;
        })
      ];
    };
}
