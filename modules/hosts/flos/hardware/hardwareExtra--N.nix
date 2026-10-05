{ inputs, ... }:

{
  flake.nixosModules.flosHardwareExtra =
    { pkgs, ... }:
    {
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

      zramSwap = {
        # More on "/modules/performance--N.nix".
        writebackDevice = "/dev/disk/by-uuid/9dd6f2a2-79c1-4365-9b82-48398f48bcc0"; # 8GiB linuxswap - WALRAM 1TB SATA 3 SSD
      };
    };
}
