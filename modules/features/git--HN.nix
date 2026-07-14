{ ... }:

{
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
      home.packages = with pkgs; [
        gitleaks
        pre-commit
        betterleaks
        git-filter-repo
      ];

      programs = {
        git = {
          enable = true;
          package = pkgs.gitFull;
        };

        git-credential-oauth = {
          enable = true;
          package = pkgs.git-credential-oauth;
        };
      };
    };
}
