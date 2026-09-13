{ inputs, ... }:

{
  /*
    # Noctalia Shell - A sleek, customizable desktop shell crafted for Wayland.
    ## Docs: https://docs.noctalia.dev/noctalia/

    # (Not Really) KDE on Niri Guide: https://gist.github.com/linhusp/05f8f7e0af3fa0fbb944dec17a75aa78
    ## Used here even if the guide is catered to the Niri window manager.

    # qtengine: https://github.com/kossLAN/qtengine
  */

  flake.nixosModules.noctaliaWithKDE =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.programs.noctalia;

      # Plasma Breeze Cursor Fix
      ## Via https://www.reddit.com/r/NixOS/comments/1htxgly/comment/m5ioyg0/
      ## Involves `home-manager.sharedModules`.
      breeze-cursor-default-theme = pkgs.runCommandLocal "breeze-cursor-default-theme" { } ''
        mkdir -p $out/share/icons

        ln -s ${pkgs.kdePackages.breeze}/share/icons/breeze_cursors $out/share/icons/default
      '';
    in
    {
      options.programs.noctalia = {
        kdeApps.enable = lib.mkEnableOption null // {
          default = true;
          example = false;
          description = ''
            Toggles the accompanying KDE desktop app suite such as file manager, document viewer, multimedia, and utilities.
          '';
        };
      };

      imports = [
        inputs.qtengine.nixosModules.default
      ];

      config = {
        environment = {
          pathsToLink = [
            "/share"
            "/libexec"
          ];

          sessionVariables = lib.mkMerge [
            {
              "QT_QPA_PLATFORM" = "wayland;xkb";

              # When not using `programs.qtengine`, setting these manually instead.
              "QT_QPA_PLATFORMTHEME" = "qtengine";
              "QT_QPA_PLATFORMTHEME_QT6" = "qtengine";
            }

            (lib.mkIf cfg.kdeApps.enable {
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
            })
          ];

          systemPackages =
            with pkgs;
            [
              ## Theming Dependencies
              ### GNOME Theming
              adw-gtk3
              nwg-look
              gnome-themes-extra

              ### Qt5, Qt6, and KDE Theming
              qtengine # Use implicit per-user `/home/$USER/.config/qtengine/config.json` than `programs.qtengine` system-wide for Noctalia.
              breeze-cursor-default-theme
              ## KColorScheme and Dolphin Noctalia dependency; Contains CLI binaries for theming; and
              ## `xembedsniproxy`, for System Tray Icons from Wine. Provided by `pkgs.kdePackages.plasma-workspace`.
              ### NOTE: This may be a heavy dependency, especially for those not wanting KDE environments.
              kdePackages.plasma-workspace

              ### Plugin Dependencies
              #### Official
              ### Screen Recording
              gpu-screen-recorder
              gpu-screen-recorder-gtk
              ### Video Wallpaper
              mpvpaper

              #### Community
              hyprpicker # Color Picker by oldirtty
            ]
            ++ lib.optionals cfg.kdeApps.enable (
              with pkgs.kdePackages;
              [
                # KDE Desktop App Suite
                ### Documents
                okular # Document viewer

                ### Multimedia
                gwenview # Image viewer

                ### Utilities
                ark # File Archiver
                kcalc # Calculator
                dolphin # File Manager
                filelight # Disk Space Visualizer

                ### Additional functionalities and plugins
                qtsvg
                qtbase
                qtwayland
                kcolorscheme
                ffmpegthumbs
                kde-cli-tools
                qtimageformats
                dolphin-plugins
                pkgs.ffmpegthumbnailer

                ### `plasma6.nix` environment packages
                ### See: https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/services/desktop-managers/plasma6.nix
                #### Frameworks with globally loadable bits
                frameworkintegration # provides Qt plugin
                qtimageformats # provides optional image formats such as .webp and .avif
                kio # provides helper service + a bunch of other stuff
                kio-admin # managing files as admin
                kio-extras # stuff for MTP, AFC, etc
                kio-fuse # fuse interface for KIO
                solid # provides solid-hardware6 tool

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
              ]
            );
        };

        # Binary Caches
        nix.settings = {
          ## Noctalia Shell
          ### See: https://docs.noctalia.dev/v5/getting-started/nixos/?section=binary-cache#binary-cache
          extra-substituters = [ "https://noctalia.cachix.org" ];
          extra-trusted-public-keys = [
            "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
          ];
        };

        programs.noctalia = {
          enable = true;
          package = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default; # From provided flake.
          systemd.enable = false;

          /*
            Contains the following required services:
            - networking.networkmanager.enable = lib.mkDefault true;
            - hardware.bluetooth.enable = lib.mkDefault true;
            - services.upower.enable = lib.mkDefault true;
            - services.power-profiles-daemon.enable = lib.mkDefault true;
          */
          recommendedServices.enable = true;
        };

        services = {
          displayManager.noctalia-greeter = {
            /*
              Enables the following required services:
              - security.polkit.enable = lib.mkDefault true;
              - services.accounts-daemon.enable = lib.mkDefault true; # For user profile synchronization.
            */
            enable = true;
            package = inputs.noctalia-greeter.packages.${pkgs.stdenv.hostPlatform.system}.default;

            settings = {
              cursor = {
                theme = "breeze_cursors";
                size = 16;
                path = "${pkgs.kdePackages.breeze}/share/icons";
              };

              keyboard = {
                numlock = false;
              };
            };
          };

          udev = {
            # Required by KDE Plasma Dolphin and `solid` to access MTP devices.
            packages = with pkgs; [
              libmtp.out
              media-player-info
            ];
          };
        };

        xdg = {
          icons = {
            enable = true;
            fallbackCursorThemes = [ "breeze_cursors" ];
          };
        };

        home-manager.sharedModules = [
          {
            xdg = {
              enable = true;

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
      };
    };
}
