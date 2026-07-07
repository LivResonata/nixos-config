{ ... }:

{
  flake.homeModules.graphics =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        # Graphics
        #krita
        #krita-plugin-gmic
        inkscape
        pixelorama
      ];
    };
}
