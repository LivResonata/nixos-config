{ inputs, ... }:

{
  flake.nixosModules.flosHardware =
    {
      config,
      lib,
      modulesPath,
      pkgs,
      ...
    }:
    {
      imports = [
        (modulesPath + "/installer/scan/not-detected.nix") # Part of auto-generation by `nixos-generate-config`.
      ];

      nix.settings = {
        # Explicitly declared as trusted for `nix-cachyos-kernel`. This is also in the input's flake, under `nixConfig`.
        substituters = [ "https://cache.lantian.pub/lantian" ];
        trusted-public-keys = [
          "lantian:WVGO7vsRMSEN+h7Lp7kv6SAmrkEXgUGbbXm7jMDjBuQ="
        ];
      };

      nixpkgs = {
        hostPlatform = "x86_64-linux"; # Part of auto-generation by `nixos-generate-config`. Removed `lib.mkDefault` prefix.

        overlays = [
          # Use the exact nixpkgs revision as defined in the nix-cachyos-kernel repo to ensure binary cache hits.
          inputs.nix-cachyos-kernel.overlays.pinned
        ];
      };

      boot = {
        plymouth.enable = false;

        # Part of auto-generation by `nixos-generate-config`.
        initrd.availableKernelModules = [
          "xhci_pci"
          "ahci"
          "usbhid"
          "usb_storage"
          "sd_mod"
        ];

        loader = {
          efi.canTouchEfiVariables = true;

          limine = {
            enable = true;
            enableEditor = false;
            secureBoot.enable = false;
            extraConfig = "timeout: 1";
          };
        };

        kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-bore-x86_64-v3;
        kernelParams = [
          # RCU Lazy - Helps reducing the power usage at idle or lightly loaded systems
          ## See: https://wiki.cachyos.org/configuration/general_system_tweaks/#enable-rcu-lazy
          "rcutree.enable_rcu_lazy=1"
        ];

        kernelModules = [
          "kvm-amd" # Part of auto-generation by `nixos-generate-config`.
          "nct6683"
        ];
      };

      hardware = {
        # Part of auto-generation by `nixos-generate-config`.
        cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

        # For monitor control
        i2c = {
          enable = true;
          group = "i2c";
        };

        sensor = {
          hddtemp = {
            enable = true;
            unit = "C";

            drives = [
              "/dev/disk/by-path/pci-0000:12:00.1-ata-1" # HDD; WDC WD5000LPLX-08ZNTT0
              "/dev/disk/by-path/pci-0000:12:00.1-ata-2" # HDD; Fujitsu MJA2250BH G2
              "/dev/disk/by-path/pci-0000:12:00.1-ata-5" # SSD; WALRAM 1TB
            ];
          };
        };
      };

      fileSystems = {
        "/" = {
          device = "/dev/disk/by-uuid/e64cca17-9b10-4143-b03f-2ca9481dfda6";
          fsType = "ext4";
          options = [ "noatime" ];
        };

        "/home" = {
          device = "/dev/disk/by-uuid/4527b575-dab2-4e79-bd63-fd8ab1a1da5e";
          fsType = "ext4";
          options = [ "noatime" ];
        };

        "/boot" = {
          device = "/dev/disk/by-uuid/7EB7-DC17";
          fsType = "vfat";
          options = [
            "fmask=0022"
            "dmask=0022"
          ];
        };

        "/media/Maackia" = {
          device = "/dev/disk/by-uuid/2e962296-bb9a-4958-9cbd-896eb742c974";
          fsType = "ext4";
          options = [ "noatime" ];
        };

        "/media/Iris" = {
          device = "/dev/disk/by-uuid/e2e4ef74-d070-4507-8bb9-3ce20a6f2860";
          fsType = "ext4";
          options = [ "noatime" ];
        };
      };

      services.udev.extraRules = ''
        # Modifies I/O scheduler to use `ADIOS` found in the CachyOS Kernel
        ## Refer to https://github.com/CachyOS/CachyOS-Settings/blob/master/usr/lib/udev/rules.d/60-ioschedulers.rules
        ## Use `cat /sys/block/DISK/queue/scheduler` to query I/O schedulers.
        ### HDD
        ACTION=="add|change", KERNEL=="sd[a-z]*", ATTR{queue/rotational}=="1", \
            ATTR{queue/scheduler}="adios"

        ### SSD
        ACTION=="add|change", KERNEL=="sd[a-z]*|mmcblk[0-9]*", ATTR{queue/rotational}=="0", \
            ATTR{queue/scheduler}="adios"

        ### NVMe SSD
        ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/rotational}=="0", \
            ATTR{queue/scheduler}="adios"
      '';

      swapDevices = lib.mkIf (config.hardware.performance.swapMode == "zswap") [
        {
          /*
            WARN: Do not use `/dev/disk/by-uuid/…` or `/dev/disk/by-label/…` as your swap device when using randomEncryption as the UUIDs
              and labels will get erased on every boot when the partition is encrypted.
            Best to use `/dev/disk/by-partuuid/…`.
          */

          device = "/dev/disk/by-partuuid/fa0202cf-d4a9-4be5-820b-6c8932b90981"; # 8GiB linuxswap - WALRAM 1TB SATA 3 SSD
          options = [
            "defaults"
            "discard=once"
          ];

          # See: https://wiki.nixos.org/wiki/Swap#Encrypt_swap_with_random_key
          randomEncryption = {
            enable = true;
            allowDiscards = true; # Allow TRIM requests for less SSD wear. Has security implications. See linked doc for more info.
          };
        }
      ];

      zramSwap = lib.mkIf (config.hardware.performance.swapMode == "zram") {
        # More on "/modules/performance--N.nix".
        writebackDevice = "/dev/disk/by-partuuid/fa0202cf-d4a9-4be5-820b-6c8932b90981"; # 8GiB linuxswap - WALRAM 1TB SATA 3 SSD
      };
    };
}
