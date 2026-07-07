{ inputs, ... }:

{
  flake.nixosModules.flosHardwareExtra =
    { ... }:
    {
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

        kernelPackages =
          inputs.nix-cachyos-kernel.legacyPackages.x86_64-linux.linuxPackages-cachyos-latest-x86_64-v3;
        kernelParams = [
          # Prevent soft lock freezing
          ## Note: Unsure if this is needed to keep.
          ## See: https://wiki.archlinux.org/title/Ryzen#Soft_lock_freezing
          "rcu_nocbs=0-3"
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
