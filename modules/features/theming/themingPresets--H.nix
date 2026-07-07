{ ... }:

{
  flake.homeModules.themingPresets =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.theming;
      availablePresets = [
        # Everforest
        "everforest-dark-medium"
      ];
    in
    {
      options.theming = {
        preset = lib.mkOption {
          type = lib.types.str;
          default = "everforest-dark-medium";
          example = "rose-pine-dawn";

          description = ''
            Active theming preset loaded in the user's environment.
            Available prests = ${lib.concatStringsSep ", " (map (c: "\"${c}\"") availablePresets)}
          '';

          apply =
            val:
            let
              invalid = if !(builtins.elem val availablePresets) then [ val ] else [ ];
            in
            if invalid != [ ] then
              abort "Invalid theming preset: \"${val}\". Valid presets are: ${
                toString (map (c: "\"${c}\"") availablePresets)
              }."
            else
              val;
        };
      };

      config = lib.mkMerge [
        # Repeating template even if some values are the same.
        (lib.mkIf (cfg.preset == "everforest-dark-medium") {
          stylix = {
            base16Scheme = "${pkgs.base16-schemes}/share/themes/everforest-dark-medium.yaml";
            polarity = "dark";

            fonts = {
              emoji = {
                name = "Noto Color Emoji";
                package = pkgs.noto-fonts-color-emoji;
              };

              monospace = {
                name = "Adwaita Mono";
                package = pkgs.adwaita-fonts;
              };

              sansSerif = {
                name = "Adwaita Sans";
                package = pkgs.adwaita-fonts;
              };

              serif = {
                name = "Noto Serif";
                package = pkgs.noto-fonts;
              };
            };
          };
        })
      ];
    };
}
