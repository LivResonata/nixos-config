{ inputs, ... }:

{
  imports = [
    # Home Manager options to Flake Parts
    inputs.home-manager.flakeModules.home-manager
  ];

  # Supported system
  systems = [
    "x86_64-linux"
  ];

  perSystem = { system, ... }: {
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;

      # Once overlayed, must declare as a package in `perSystem.packages`
      # in "./perSystemPackages.nix".
      overlays = [
        (import ../overlays/vram-patch/overlays.nix)
      ];

      # Declare nixpkgs config here to affect `perSystem.packages`
      # in "./perSystemPackages.nix".
      config = {
        allowUnfree = true;
      };
    };
  };
}
