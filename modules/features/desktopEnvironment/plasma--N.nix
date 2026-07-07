{ ... }:

{
  flake.nixosModules.plasma =
    { pkgs, ... }:
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
      services = {
        desktopManager.plasma6.enable = true;
        displayManager.plasma-login-manager.enable = true;
      };

      xdg.portal = {
        config.common.default = "kde";
        extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
      };

      environment = {
        plasma6.excludePackages = with pkgs.kdePackages; [
          discover
        ];

        # Extra packages outside `plasma6.nix` in Nixpkgs.
        systemPackages = with pkgs.kdePackages; [
          krfb
          kio-gdrive
          ktextaddons
          kdbusaddons
          kio-zeroconf
          kdepim-addons
          kwidgetsaddons
          kirigami-addons
          kaccounts-providers
          kaccounts-integration
          applet-window-buttons6
          breeze-cursor-default-theme
        ];
      };

      home-manager.sharedModules = [
        {
          xdg = {
            enable = true;

            dataFile = {
              # Plasma Breeze Cursor Fix
              ## Via https://www.reddit.com/r/NixOS/comments/1htxgly/comment/m5ioyg0/
              ## Involves `flake.nixosModules.plasma`.
              "icons/default".source = "${pkgs.kdePackages.breeze}/share/icons/breeze_cursors";
            };
          };
        }
      ];
    };
}
