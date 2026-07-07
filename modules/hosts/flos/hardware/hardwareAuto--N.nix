{ ... }:
{
  flake.nixosModules.flosHardwareAuto =
    {
      config,
      lib,
      modulesPath,
      ...
    }:
    {
      # Auto-generated file by `nixos-generate-config`. Do not modify!
      # Ported to Flake Parts and the Dedritic Pattern.
      imports = [
        (modulesPath + "/installer/scan/not-detected.nix")
      ];

      boot = {
        initrd.availableKernelModules = [
          "xhci_pci"
          "ahci"
          "usbhid"
          "usb_storage"
          "sd_mod"
        ];
        initrd.kernelModules = [ ];
        kernelModules = [ "kvm-amd" ];
        extraModulePackages = [ ];
      };

      fileSystems = {
        "/" = {
          device = "/dev/disk/by-uuid/e64cca17-9b10-4143-b03f-2ca9481dfda6";
          fsType = "ext4";
        };

        "/home" = {
          device = "/dev/disk/by-uuid/4527b575-dab2-4e79-bd63-fd8ab1a1da5e";
          fsType = "ext4";
        };

        "/boot" = {
          device = "/dev/disk/by-uuid/7EB7-DC17";
          fsType = "vfat";
          options = [
            "fmask=0022"
            "dmask=0022"
          ];
        };

        "/media/Iris" = {
          device = "/dev/disk/by-uuid/e2e4ef74-d070-4507-8bb9-3ce20a6f2860";
          fsType = "ext4";
        };
      };

      swapDevices = [ ];

      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
      hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    };
}
