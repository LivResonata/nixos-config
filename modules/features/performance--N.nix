{ inputs, ... }:

{
  flake.nixosModules.performance =
    {
      config,
      lib,
      packages,
      pkgs,
      ...
    }:
    let
      cfg = config.hardware.performance;
    in
    {
      options.hardware.performance = {
        dmemcg.enable = lib.mkEnableOption null // {
          default = false;
          example = true;
          description = ''
            Enables dmemcg-booster and dependencies for dGPU memory management.
            Currently supports: KDE Plasma and Niri

            May not or does not have any effect to systems using only an iGPU.
          '';
        };
      };

      imports = [
        inputs.preload-ng.nixosModules.default
      ];

      config = lib.mkMerge [
        (lib.mkIf cfg.dmemcg.enable {
          environment.systemPackages =
            with packages;
            [
              kcgroups
              dmemcg-booster
            ]
            ++ lib.optionals config.services.desktopManager.plasma6.enable [
              plasma-foreground-booster
            ]
            ++ lib.optionals config.programs.niri.enable [
              # Add `spawn-at-startup "niri-focused-booster"` to Niri configuration to use it.
              niri-focused-booster
            ];

          # dmemcg-booster services
          systemd = {
            services.dmemcg-booster-system = {
              enable = true;
              wantedBy = [ "multi-user.target" ];
              description = "Service for enabling and controlling dmem cgroup limits for boosting foreground games, system-level";
              #overrideStrategy = "asDropin";

              serviceConfig = {
                ExecStart = "/run/current-system/sw/bin/dmemcg-booster --use-system-bus";
              };
            };

            user.services.dmemcg-booster-user = {
              overrideStrategy = "asDropin";
              wantedBy = [ "graphical-session-pre.target" ];
            };
          };
        })

        {
          boot = {
            kernel.sysctl = {
              "kernel.core_pattern" = "|/bin/false"; # Disables coredump

              # ZRAM Parameters
              "vm.swappiness" = 150;
              "vm.watermark_scale_factor" = 125;
            };

            kernelParams = [
              # No swap partition auto-mount for ZRAM Writeback
              ## See: https://wiki.nixos.org/wiki/Swap#Zram_writeback
              ##      https://wiki.nixos.org/wiki/Swap#Disable_swap
              "systemd.swap=0"
            ];
          };

          services = {
            power-profiles-daemon.enable = true;

            ananicy = {
              enable = true;
              package = pkgs.ananicy-cpp;
              rulesProvider = pkgs.ananicy-rules-cachyos;
            };

            # Preload-NG Docs
            ## See: https://github.com/miguel-b-p/preload-ng/blob/main/doc/README.md
            preload-ng = {
              enable = true;
              usePrecompiled = true;
            };

            scx = {
              enable = false; # Use CachyOS kernel's default EEVDF CPU scheduler for now.
              package = pkgs.scx.rustscheds;
              scheduler = "scx_cake";
              extraArgs = [ "--profile gaming" ];
            };
          };

          systemd.coredump = {
            # Disabling will make coredumps be made in a crashing process' directory.
            # Otherwise, enabling will let systemd-coredump handle crashes instead.
            enable = true;

            # Disable coredump handled by systemd
            settings.Coredump = {
              Storage = "none";
              ProcessSizeMax = 0;
            };
          };

          # Memory Management
          systemd.oomd.enable = false; # CachyOS disabled OOMD and solely uses `le9`.
          zramSwap = {
            enable = true;
            priority = 100;
            algorithm = "zstd";
            memoryPercent = 90;
          };
        }
      ];
    };
}
