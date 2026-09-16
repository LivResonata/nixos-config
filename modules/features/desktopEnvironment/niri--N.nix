{ ... }:

{
  # Niri scrollable-tiling window manager with Noctalia Shell
  ## Docs: https://wiki.nixos.org/wiki/Niri

  flake.nixosModules.niri =
    {
      config,
      lib,
      packages,
      pkgs,
      ...
    }:
    {
      environment.systemPackages = with pkgs; [
        # Niri
        ## Required
        xwayland-satellite

        ## Superseded Requirements
        #nautilus # Preferred file manager is `pkgs.kdePackages.dolphin`, included in `noctaliaWithKDE` module.
        #kdePackages.polkit-kde-agent-1 # Noctalia Shell has a polkit manager
      ];

      programs = {
        dconf.enable = true;

        niri = {
          enable = true;
          package = packages.niri-patched;
          useNautilus = false;
        };
      };

      services = {
        gnome.gnome-keyring.enable = true; # Required by Niri, not interchangeable.

        udev = {
          packages = with pkgs; [
            libmtp.out
            media-player-info
          ];
        };
      };

      xdg = {
        portal = {
          configPackages = [ pkgs.kdePackages.plasma-workspace ];

          extraPortals = with pkgs; [
            xdg-desktop-portal-gtk
            xdg-desktop-portal-gnome
            kdePackages.xdg-desktop-portal-kde
          ];

          config.niri = {
            "default" = lib.mkForce [ "gnome" ];
            "org.freedesktop.impl.portal.Access" = lib.mkForce [ "gtk" ];
            "org.freedesktop.impl.portal.Secret" = lib.mkForce [ "gnome-keyring" ];
            "org.freedesktop.impl.portal.FileChooser" = lib.mkForce [ "kde" ];
            "org.freedesktop.impl.portal.Notification" = lib.mkForce [ "gtk" ];
          };
        };
      };

      home-manager.sharedModules = [
        {
          xdg = {
            enable = true;

            configFile = {
              # Niri takes this file with the highest priority over NixOS options.
              "niri/niri-portals.conf".text = ''
                [preferred]
                default=${config.xdg.portal.config.niri."default"};
                org.freedesktop.impl.portal.Access=${
                  config.xdg.portal.config.niri."org.freedesktop.impl.portal.Access"
                };
                org.freedesktop.impl.portal.Secret=${
                  config.xdg.portal.config.niri."org.freedesktop.impl.portal.Secret"
                };
                org.freedesktop.impl.portal.FileChooser=${
                  config.xdg.portal.config.niri."org.freedesktop.impl.portal.FileChooser"
                };
                org.freedesktop.impl.portal.Notification=${
                  config.xdg.portal.config.niri."org.freedesktop.impl.portal.Notification"
                };
              '';
            };
          };
        }
      ];

      # NixOS otherwise injects a stripped PATH via Environment= on the niri.service
      # unit which shadows the imported user-manager PATH. Disabling the default
      # lets niri inherit the full PATH set up by niri-session.
      systemd.user.services.niri.enableDefaultPath = false;
    };
}
