{ ... }:

{
  flake.nixosModules.fonts =
    { pkgs, ... }:
    {
      fonts = {
        fontDir.enable = true;
        enableDefaultPackages = true;

        fontconfig = {
          useEmbeddedBitmaps = true;

          # Only allow embedded bitmap for Noto Color Emoji.
          ## If false, applications such as Mozilla Firefox fails
          ## to render the font; making the character invisible.
          localConf = ''
            <?xml version="1.0"?>
            <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
            <fontconfig>
              <match target="pattern">
                <test qual="any" name="family" compare="not_eq">
                  <string>Noto Color Emoji</string>
                </test>
                <edit name="embeddedbitmap" mode="assign">
                  <bool>false</bool>
                </edit>
              </match>
            </fontconfig>
          '';
        };

        packages = with pkgs; [
          # CJK Fonts
          noto-fonts-cjk-sans
          noto-fonts-cjk-serif

          # Microsoft Web Fonts
          corefonts

          # Sans-serif
          adwaita-fonts
          inter-nerdfont

          # Nerd Fonts - Developer-targeted fonts with more symbols
          nerd-fonts.space-mono
          nerd-fonts.adwaita-mono
          nerd-fonts.iosevka-term-slab
        ];
      };
    };
}
