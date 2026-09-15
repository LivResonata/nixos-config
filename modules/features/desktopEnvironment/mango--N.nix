{ inputs, ... }:

{
  flake.nixosModules.mango =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.programs.mango;
    in
    {
      options.programs.mango = {
        graphicsCompatibility.enable = lib.mkEnableOption null // {
          default = false;
          example = true;
          description = ''
            Some GPUs have compatibility issues with `syncobj_enable=1`
            as it may crash apps like kitty that use syncobj.

            Requires restart of Mango to apply changes.
          '';
          ## See: https://mangowm.github.io/docs/configuration/monitors#graphics-card-compatibility
        };

        withUWSM.enable = lib.mkEnableOption null // {
          default = false;
          exmaple = true;
          description = ''
            Launch Mango with the UWSM (Universal Wayland Session Manager).
          '';
        };
      };

      imports = [
        inputs.mangowm.nixosModules.mango
      ];

      config = {
        environment.sessionVariables = lib.mkMerge [
          (lib.mkIf cfg.graphicsCompatibility.enable {
            "WLR_DRM_NO_ATOMIC" = 1;
          })
        ];

        programs = lib.mkMerge [
          {
            mango.enable = true;
          }

          (lib.mkIf cfg.withUWSM.enable {
            uwsm = {
              enable = true;

              waylandCompositors.mango = {
                prettyName = "Mango";
                comment = "Mango compositor managed by UWSM";
                binPath = "/run/current-system/sw/bin/mango";
              };
            };
          })
        ];

        services.gnome.gnome-keyring.enable = true; # Defaults uses the `gnome-keyring`.

        xdg = {
          portal = {
            configPackages = [ pkgs.kdePackages.plasma-workspace ];

            extraPortals = [
              # MangoWM Flake already provides `wlr` and `gtk`.
              pkgs.kdePackages.xdg-desktop-portal-kde
            ];

            config.mango = {
              "default" = lib.mkForce [ "gtk" ];
              "org.freedesktop.impl.portal.Secret" = lib.mkForce [ "gnome-keyring" ];
              "org.freedesktop.impl.portal.Inhibit" = lib.mkForce [ "none" ];
              "org.freedesktop.impl.portal.ScreenCast" = lib.mkForce [ "wlr" ];
              "org.freedesktop.impl.portal.Screenshot" = lib.mkForce [ "wlr" ];
              "org.freedesktop.impl.portal.FileChooser" = lib.mkForce [ "kde" ];
            };
          };
        };

        home-manager.sharedModules = [
          {
            imports = [
              inputs.mangowm.hmModules.mango
            ];

            xdg = {
              enable = true;

              configFile = {
                # MangoWM takes this file with the highest priority, and may be over NixOS options.
                "xdg-desktop-portal/mango-portals.conf".text = ''
                  [preferred]
                  default=${config.xdg.portal.config.niri."default"};
                  org.freedesktop.impl.portal.Secret=${
                    config.xdg.portal.config.mango."org.freedesktop.impl.portal.Secret"
                  };
                  org.freedesktop.impl.portal.Inhibit=${
                    config.xdg.portal.config.mango."org.freedesktop.impl.portal.Inhibit"
                  };
                  org.freedesktop.impl.portal.ScreenCast=${
                    config.xdg.portal.config.mango."org.freedesktop.impl.portal.ScreenCast"
                  };
                  org.freedesktop.impl.portal.Screenshot=${
                    config.xdg.portal.config.mango."org.freedesktop.impl.portal.Screenshot"
                  };
                  org.freedesktop.impl.portal.FileChooser=${
                    config.xdg.portal.config.mango."org.freedesktop.impl.portal.FileChooser"
                  };
                '';
              };
            };
          }
        ];
      };
    };
}
