{ inputs, ... }:

{
  # Niri scrollable-tiling window manager with Noctalia Shell
  ## Niri Docs: https://wiki.nixos.org/wiki/Niri
  ## Noctalia Shell v5 Docs: https://docs.noctalia.dev/v5/
  ## (Not Really) KDE on Niri Guide: https://gist.github.com/linhusp/05f8f7e0af3fa0fbb944dec17a75aa78
  ## qtengine: https://github.com/kossLAN/qtengine

  flake.nixosModules.niri =
    {
      config,
      lib,
      packages,
      pkgs,
      ...
    }:
    let
      # Plasma Breeze Cursor Fix
      ## Via https://www.reddit.com/r/NixOS/comments/1htxgly/comment/m5ioyg0/
      ## Involves `home-manager.sharedModules`.
      breeze-cursor-default-theme = pkgs.runCommandLocal "breeze-cursor-default-theme" { } ''
        mkdir -p $out/share/icons

        ln -s ${pkgs.kdePackages.breeze}/share/icons/breeze_cursors $out/share/icons/default
      '';
    in
    {
      imports = [
        inputs.qtengine.nixosModules.default
        inputs.noctalia-greeter.nixosModules.default
      ];

      hardware.bluetooth.enable = true;

      environment = {
        pathsToLink = [
          "/share"
          "/libexec"
        ];

        sessionVariables = {
          "QT_QPA_PLATFORM" = "wayland;xkb";

          # When not using `programs.qtengine`, setting these manually instead.
          "QT_QPA_PLATFORMTHEME" = "qtengine";
          "QT_QPA_PLATFORMTHEME_QT6" = "qtengine";

          # Helps fixing Dolphin default applications issue.
          "XDG_MENU_PREFIX" = "plasma-";

          "QT_AUTO_SCREEN_SCALE_FACTOR" = 1;
          "QT_ENABLE_HIGHDPI_SCALING" = 1;
          "QT_SCALE_FACTOR_ROUNDING_POLICY" = "RoundPreferFloor";

          "GTK_DECORATION_LAYOUT" = "";

          ### `plasma6.nix` environment variables
          ### See: https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/services/desktop-managers/plasma6.nix
          "XDG_CONFIG_DIRS" = [ "$HOME/.config/kdedefaults" ];
          "KPACKAGE_DEP_RESOLVERS_PATH" =
            "${pkgs.kdePackages.frameworkintegration.out}/libexec/kf6/kpackagehandlers";
        };

        systemPackages = lib.mkMerge [
          (with pkgs; [
            # Noctalia Shell
            ## Required
            xwayland-satellite
            inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default

            ## Superseded Requirements
            #nautilus # Preferred file manager is `kdePackages.dolphin`.
            #kdePackages.polkit-kde-agent-1 # Noctalia Shell has a polkit manager

            ## Optional Dependencies
            ### GNOME Theming
            adw-gtk3
            nwg-look
            gnome-themes-extra

            ### Qt5, Qt6, and KDE Theming
            qtengine # Use implicit per-user `/home/$USER/.config/qtengine/config.json` than `programs.qtengine` system-wide for Noctalia.
            breeze-cursor-default-theme
            kdePackages.plasma-workspace # KColorScheme and Dolphin Noctalia dependency; Contains CLI binaries for theming.

            ### Screen Recording
            gpu-screen-recorder
            gpu-screen-recorder-gtk
          ])

          (with pkgs.kdePackages; [
            # Desktop App Suite
            ## Currently mainly targeting KDE Plasma Apps.
            ## Intentionally not going for GNOME due to preference.
            ### Documents
            okular # Document viewer

            ### Multimedia
            gwenview # Image viewer

            ### Screenshot
            #### As closest to spectacle— isn't compatible outside KDE Plasma.
            #### Niri and Noctalia Shell also provide their own screenshot system, if preferred.
            pkgs.grim
            pkgs.satty

            ### Utilities
            ark # File Archiver
            kcalc # Calculator
            dolphin # File Manager
            filelight # Disk Space Visualizer
            plasma-systemmonitor # System Monitor

            ### Additional functionalities and plugins
            qtsvg
            qtbase
            qtwayland
            kcolorscheme
            ffmpegthumbs
            # kconfigwidgets
            qtimageformats
            dolphin-plugins
            pkgs.ffmpegthumbnailer

            ### `plasma6.nix` environment packages
            ### See: https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/services/desktop-managers/plasma6.nix
            #### Frameworks with globally loadable bits
            frameworkintegration # provides Qt plugin
            kded # provides helper service
            qtimageformats # provides optional image formats such as .webp and .avif
            kio # provides helper service + a bunch of other stuff
            kio-admin # managing files as admin
            kio-extras # stuff for MTP, AFC, etc
            kio-fuse # fuse interface for KIO

            #### Core Plasma Parts
            kdegraphics-thumbnailers # pdf etc thumbnailer

            #### Artwork + Themes
            breeze
            breeze-icons
            breeze-gtk
            pkgs.hicolor-icon-theme # fallback icons
            qqc2-breeze-style
            qqc2-desktop-style

            # Misc Plasma Extras
            pkgs.xdg-user-dirs # recommended upstream
          ])
        ];
      };

      networking.networkmanager.enable = true;

      programs = {
        dconf.enable = true;

        niri = {
          enable = true;
          package = packages.niri-patched;
          useNautilus = false;
        };

        noctalia-greeter = {
          enable = true;
          package = inputs.noctalia-greeter.packages.${pkgs.stdenv.hostPlatform.system}.default;
          greeter-args = "--session niri";

          settings.cursor = {
            theme = "Breeze Dark";
            size = 16;
            package = pkgs.kdePackages.breeze;
          };
        };
      };

      security.polkit.enable = true;

      services = {
        upower.enable = true;
        gnome.gnome-keyring.enable = true; # Required by Noctalia Shell, not interchangeable.
        power-profiles-daemon.enable = true;

        greetd = {
          enable = true;
          settings = {
            default_session = {
              command = "/run/current-system/sw/bin/noctalia-greeter-session";
              user = "greeter";
            };
          };
        };
      };

      xdg = {
        icons = {
          enable = true;
          fallbackCursorThemes = [ "breeze_cursors" ];
        };

        portal = {
          configPackages = [ pkgs.kdePackages.plasma-workspace ];

          extraPortals = [
            pkgs.xdg-desktop-portal-gtk
            pkgs.xdg-desktop-portal-gnome
            pkgs.kdePackages.xdg-desktop-portal-kde
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

            dataFile = {
              # Plasma Breeze Cursor Fix
              ## Via https://www.reddit.com/r/NixOS/comments/1htxgly/comment/m5ioyg0/
              ## Involves `flake.nixosModules.plasma`.
              #"icons/default".source = "${pkgs.kdePackages.breeze}/share/icons/breeze_cursors";

              # Backup in case of `pkgs.nwg-look` conflict.
              "icons/breeze_cursors".source = "${pkgs.kdePackages.breeze}/share/icons/breeze_cursors";
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
