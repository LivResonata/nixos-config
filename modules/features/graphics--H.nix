{ ... }:

{
  flake.homeModules.graphics =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        # 3D Modeling
        blender

        # Digital Art
        /*
          NOTE: Krita and Inkscape has oddities if installed via Nixpkgs. Alternative setup is in Flatpak instead.
          - Krita: Nixpkgs version uses 6.x release where Flatpak uses 5.x. The latter is more stable.
          - Inkscape: Crash bug when moving layers inside groups. See: https://gitlab.com/inkscape/inbox/-/work_items/13567
        */
        pixelorama

        # Video Editing
        kdePackages.kdenlive
      ];
    };
}
