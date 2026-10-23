{ ... }:

{
  flake.homeModules.git =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        # Operations (ops)
        gitleaks
        pre-commit
        betterleaks
        git-filter-repo
      ];

      programs = {
        lazygit.enable = true;

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

}
