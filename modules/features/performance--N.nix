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

      swapModeList = [
        "zswap"
        "zram"
      ];
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

        swapMode = lib.mkOption {
          type = lib.types.str;
          default = "zram";
          example = "zswap";
          description = ''
            Either use `zram` or `zswap` for compressed memory and swap space.

            Generally, it is recommend to use `zswap` if disk swap is available due to better
              kernel memory integration. Otherwise, `zram` if no disk swap or have memory constraints.
          '';

          apply =
            swap:
            let
              invalid = if !(builtins.elem swap swapModeList) then [ swap ] else [ ];
            in
            if invalid != [ ] then
              abort "Invalid `swapMode` value: \"${swap}\". Valid options are: ${
                toString (map (c: "\"${c}\"") swapModeList)
              }."
            else
              swap;
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
            kernel.sysctl = lib.mkMerge [
              {
                "kernel.core_pattern" = "|/bin/false"; # Disables coredump
              }

              (lib.mkIf (cfg.swapMode == "zram") {
                # ZRAM Parameters
                "vm.swappiness" = 150;
                "vm.watermark_scale_factor" = 125;
              })
            ];

            kernelParams =
              [ ]
              ++ lib.optionals (cfg.swapMode == "zram") [
                # No swap partition auto-mount for ZRAM Writeback
                ## See: https://wiki.nixos.org/wiki/Swap#Zram_writeback
                ##      https://wiki.nixos.org/wiki/Swap#Disable_swap
                "systemd.swap=0"
              ]
              ++ lib.optionals (cfg.swapMode == "zswap") [
                # Disable to disallow the feature that can cause resume failure on startup.
                # See: https://wiki.archlinux.org/title/Dm-crypt/Swap_encryption#Disabling_hibernation
                "hibernate=0"
              ];

            zswap = {
              # See: https://wiki.nixos.org/wiki/Swap#Zswap_swap_cache
              enable = if cfg.swapMode == "zswap" then true else false;
              zpool = "zsmalloc";
              compressor = "zstd";
              maxPoolPercent = 25;
              shrinkerEnabled = true;
              acceptThresholdPercent = 90;
            };
          };

          services = {
            power-profiles-daemon.enable = true;

            ananicy = {
              enable = true;
              package = pkgs.ananicy-cpp;
              rulesProvider = pkgs.ananicy-rules-cachyos_git; # Provided by Chaotic-Nyx
            };

            # Preload-NG Docs
            ## See: https://github.com/miguel-b-p/preload-ng/blob/main/doc/README.md
            preload-ng = {
              enable = true;
              usePrecompiled = true;
            };

            scx = {
              enable = lib.mkDefault true;
              package = pkgs.scx.rustscheds;
              scheduler = "scx_cake";
              extraArgs = [ ];
            };
          };

          systemd = {
            oomd.enable = false; # CachyOS disabled OOMD and solely uses `le9` for their kernel.

            coredump = {
              # Disabling will make coredumps be made in a crashing process' directory.
              # Otherwise, enabling will let systemd-coredump handle crashes instead.
              enable = true;

              # Disable coredump handled by systemd
              settings.Coredump = {
                Storage = "none";
                ProcessSizeMax = 0;
              };
            };
          };

          zramSwap = {
            enable = if cfg.swapMode == "zram" then true else false;
            priority = 100;
            algorithm = "zstd";
            memoryPercent = 90;
          };
        }
      ];
    };
}
