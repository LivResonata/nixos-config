{ ... }:

{
  flake.nixosModules.fonts =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.fonts;
    in
    {
      options.fonts.monochromeEmoji = {
        enable = lib.mkEnableOption null // {
          default = false;
          exmaple = true;
          description = ''
            Use Noto Emoji, a monochrome emoji font, as opposed to Noto Color Emoji.
          '';
        };
      };

      config = {
        fonts = {
          fontDir.enable = true;
          enableDefaultPackages = false; # Manually installed instead.

          fontconfig = {
            enable = true;
            antialias = false; # Not needed for >200 DPI/PPI displays.
            useEmbeddedBitmaps = true;

            # TODO: Revamp theming modularity alongside Stylix if these are customized. This seems out-of-place.
            defaultFonts = {
              emoji = lib.mkDefault [ (if cfg.monochromeEmoji.enable then "Noto Emoji" else "Noto Color Emoji") ];
              monospace = lib.mkDefault [
                "DepartureMono Nerd Font Mono Propo"
                "Adwaita Mono"
              ];
              sansSerif = lib.mkDefault [
                "DepartureMono Nerd Font Mono Propo"
                "Adwaita Sans"
              ];
              serif = lib.mkDefault [ "Noto Serif" ];
            };

            hinting = {
              enable = true;
              style = "slight";
            };

            subpixel = {
              rgba = "rgb";
              lcdfilter = "none"; # Also not needed for >200 DPI/PPI displays.
            };
          };

          packages = with pkgs; [
            # Default Font Packages
            unifont
            gyre-fonts # TrueType substitutes for standard PostScript fonts
            dejavu_fonts
            freefont_ttf
            liberation_ttf

            # Emoji
            ## Choose only one at a time. Cannot coexist as both.
            (if cfg.monochromeEmoji.enable then noto-fonts-monochrome-emoji else noto-fonts-color-emoji)

            # Microsoft Web Fonts
            corefonts

            # Noto Fonts
            noto-fonts
            noto-fonts-cjk-sans
            noto-fonts-cjk-serif

            # Sans-serif
            inter
            adwaita-fonts

            # Nerd Fonts - Developer-targeted fonts with more symbols
            nerd-fonts.adwaita-mono
            nerd-fonts.departure-mono
          ];
        };
      };
    };
}
