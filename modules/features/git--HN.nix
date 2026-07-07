{ ... }:

{
  # Not sure if this feature module is needed at all.
  # Might move to `commonPrograms--HN.nix` other than serving as
  # a visual presence indicator in a host or user's feature list.

  flake.nixosModules.git =
    { pkgs, ... }:
    {
      programs = {
        git = {
          enable = true;
          package = pkgs.gitFull;
        };
      };
    };

  flake.homeModules.git =
    { pkgs, ... }:
    {
      programs = {
        git = {
          enable = true;
          package = pkgs.gitFull;
        };
      };
    };
}
