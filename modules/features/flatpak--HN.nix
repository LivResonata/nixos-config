{ inputs, ... }:

{
  flake.homeModules.flatpak =
    {
      config,
      lib,
      osConfig,
      ...
    }:
    let
      cfg = config.services.flatpak;
      validCategories = [
        "audio"
        "gaming"
        "graphics"
        "noctalia"
        "sensitives"
      ];

      sensitivesSecretsPath = toString inputs.sensitivesSecrets;
      sensitivesSecretsData = builtins.fromJSON (
        builtins.readFile "${sensitivesSecretsPath}/sensitives.json"
      );
    in
    {
      options.services.flatpak = {
        # Generated with Proton's Lumo AI. Hoping to understand this as I continue learning Nix.
        extraCategories = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];

          description = "Extra categories of packages to include. Options: ${
            lib.concatStringsSep ", " (map (c: "\"${c}\"") validCategories)
          }";

          apply =
            cats:
            let
              invalid = lib.filter (c: !(lib.elem c validCategories)) cats;
            in
            if invalid != [ ] then
              abort "Unknown 'services.flatpak.extraCategory' entry: [ ${
                toString (map (c: "\"${c}\"") invalid)
              } ]. Valid options are: [ ${toString (map (c: "\"${c}\"") validCategories)} ]."
            else
              cats;
        };
      };

      imports = [
        inputs.nix-flatpak.homeManagerModules.nix-flatpak
      ];

      config = {
        assertions = [
          {
            assertion = osConfig.services.flatpak.enable;
            message = ''
              'flake.homeModules.flatpak' requires 'services.flatpak.enable' to be true.
              Add 'flake.nixosModules.flatpak' to your NixOS modules to do so or declare elsewhere.
            '';
          }
        ];

        services = {
          flatpak = {
            uninstallUnmanaged = true;
            update.onActivation = true;

            # Some packages may require a specified ref or has no `stable` branch. Use solution in referred link for a fix.
            ## Specified versioning format: "<pkg ref>/<architecture>/<branch>"
            ##  (e.g. "org.freedesktop.Platform.VulkanLayer.MangoHud/x86_64/25.08")
            ## See: https://github.com/gmodena/nix-flatpak/discussions/109
            packages = [
              "com.usebottles.bottles" # Bottles
              "rocks.koreader.KOReader" # KOReader
              "org.nickvision.tubeconverter" # Parabolic
              "com.obsproject.Studio.Plugin.OBSVkCapture" # OBS Vulkan Capture (for Bottles)
              "org.freedesktop.Platform.VulkanLayer.MangoHud/x86_64/25.08" # MangoHud (for Bottles)
              "org.freedesktop.Platform.VulkanLayer.vkBasalt/x86_64/25.08" # vkBasalt (for Bottles)
              "org.freedesktop.Platform.VulkanLayer.gamescope/x86_64/25.08" # Gamescope (for Bottles)
            ]
            ++ lib.optionals (lib.lists.any (cat: lib.strings.hasInfix "audio" cat) cfg.extraCategories) [
              "com.github.wwmm.easyeffects" # Easy Effects
            ]
            ++ lib.optionals (lib.lists.any (cat: lib.strings.hasInfix "gaming" cat) cfg.extraCategories) [
              "sh.ppy.osu" # osu! (Unofficial package)
              "com.github.Matoking.protontricks" # Protontricks
            ]
            ++ lib.optionals (lib.lists.any (cat: lib.strings.hasInfix "graphics" cat) cfg.extraCategories) [
              "org.kde.krita" # Krita
            ]
            ++ lib.optionals (lib.lists.any (cat: lib.strings.hasInfix "noctalia" cat) cfg.extraCategories) [
              "org.gtk.Gtk3theme.adw-gtk3" # adw-gtk3 GTK Theme
              "org.gtk.Gtk3theme.adw-gtk3-dark" # adw-gtk3 GTK Theme
            ]
            ++ lib.optionals (lib.lists.any (cat: lib.strings.hasInfix "sensitives" cat) cfg.extraCategories) [
              sensitivesSecretsData.flatpak.sensitives
            ];
          };
        };
      };
    };

  flake.nixosModules.flatpak =
    { ... }:
    {
      services.flatpak.enable = true;
    };
}
