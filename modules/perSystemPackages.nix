{ ... }:

# Isolated perSystem module that only deals with `perSystem.packages`.
# Avoids conflict with `_module.args.pkgs` in "./parts.nix".
{
  perSystem =
    {
      pkgs,
      ...
    }:
    {
      # Overlays (Consumed)
      ## Must first be imported and overlayed in `./parts.nix`.
      packages.kcgroups = pkgs.kcgroups;
      packages.dmemcg-booster = pkgs.dmemcg-booster;
      packages.niri-focused-booster = pkgs.niri-focused-booster;
      packages.plasma-foreground-booster = pkgs.plasma-foreground-booster;

      # Packages
      packages.dwproton = pkgs.callPackage ../pkgs/by-name/dwproton/dwproton.nix { };
      packages.niri-patched = pkgs.callPackage ../pkgs/by-name/niri-patched/niri-patched.nix { };
      packages.veikk-driver-gui =
        pkgs.callPackage ../pkgs/by-name/veikk-driver-gui/veikk-driver-gui.nix
          { };
    };
}
