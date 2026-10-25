{ inputs, ... }:

{
  flake.nixosModules.flosHardwareExtra =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      nix.settings = {
        # Explicitly declared as trusted for `nix-cachyos-kernel`. This is also in the input's flake, under `nixConfig`.
        substituters = [ "https://cache.lantian.pub/lantian" ];
        trusted-public-keys = [
          "lantian:WVGO7vsRMSEN+h7Lp7kv6SAmrkEXgUGbbXm7jMDjBuQ="
        ];
      };

      nixpkgs.overlays = [
        # Use the exact nixpkgs revision as defined in the nix-cachyos-kernel repo to ensure binary cache hits.
        inputs.nix-cachyos-kernel.overlays.pinned
      ];

      boot = {
        plymouth.enable = false;

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

        kernelModules = [ "nct6683" ];
      };

      hardware = {
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
              "/dev/disk/by-path/pci-0000:12:00.1-ata-5.0" # HDD; Fujitsu MJA2250BH G2
              "/dev/disk/by-path/pci-0000:12:00.1-ata-6.0" # SSD; WALRAM 1TB
            ];
          };
        };
      };

      # Additional Filesystem Options (/etc/fstab)
      fileSystems = {
        "/home" = {
          options = [ "noatime" ];
        };

        "/media/Iris" = {
          options = [
            "noatime"
            "nofail"
          ];
        };
        "/media/Maackia" = {
          options = [
            "noatime"
            "nofail"
          ];
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
            "discard"
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
