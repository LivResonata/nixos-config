{ ... }:

{
  /*
    WARN: Mixing GNOME with other desktops (such as alternative login managers other than GDM)
          is not supported, make sure to disable other desktop modules before rebuilding
          if you encounter issues with conflicting desktops.
  */

  flake.nixosModules.gnome =
    { pkgs, packages, ... }:
    {
      environment.systemPackages = with pkgs; [
        # App Indicator (App Tray)
        gnomeExtensions.appindicator

        # Core Developer Tools
        dconf-editor

        # Customization
        adw-gtk3
        nwg-look
        gnome-tweaks
        packages.refine

        # Games
        gnome-chess
        gnome-mines

        # QT Theming
        # See: https://wiki.nixos.org/wiki/GNOME#Qt_integration_for_GNOME
        ## Themes the app title bars.
        qadwaitadecorations
        qadwaitadecorations-qt6
        ## Themes the apps.
        qgnomeplatform
        qgnomeplatform-qt6
      ];

      services = {
        displayManager.gdm.enable = true;
        desktopManager.gnome.enable = true;

        gnome = {
          core-apps.enable = true;
          core-developer-tools.enable = false;
          games.enable = false;
        };
      };
    };
}
