{ ... }:

{
  flake.homeModules.graphics =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        # 3D Modeling
        blender

        # Digital Art
        inkscape
        pixelorama

        # Video Editing
        kdePackages.kdenlive
      ];
    };
}
