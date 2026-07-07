{ ... }:

{
  flake.nixosModules.drawingTablet =
    {
      config,
      lib,
      packages,
      ...
    }:
    let
      cfg = config.hardware.drawingTablet;
      platformList = [
        "opentabletdriver"
        "veikk"
      ];
    in
    {
      options.hardware.drawingTablet = {
        platform = lib.mkOption {
          type = lib.types.str;
          default = "opentabletdriver";
          example = "veikk";

          description = ''
            Active program used to connect and manage to a drawing tablet or pen display.
            Available platforms = ${lib.concatStringsSep ", " (map (c: "\"${c}\"") platformList)}
          '';

          apply =
            val:
            let
              invalid = if !(builtins.elem val platformList) then [ val ] else [ ];
            in
            if invalid != [ ] then
              abort "Invalid theming preset: \"${val}\". Valid presets are: ${
                toString (map (c: "\"${c}\"") platformList)
              }."
            else
              val;
        };
      };

      config = lib.mkMerge [
        (lib.mkIf (cfg.platform == "opentabletdriver") {
          hardware = {
            opentabletdriver = {
              enable = true;
              daemon.enable = true;
            };
          };

        })

        (lib.mkIf (cfg.platform == "veikk") {
          environment.systemPackages = with packages; [
            veikk-driver-gui
          ];
        })

        {
          # Required to detect the pen regardless of platform choice.
          services.udev.packages = with packages; [
            veikk-driver-gui # VEIKK 1200
          ];
        }
      ];
    };
}
