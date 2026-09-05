{ ... }:

{
  flake.homeModules.shell =
    { config, pkgs, ... }:
    {
      home.packages = with pkgs; [
        # CLI
        starship
      ];

      programs = {
        # Disable Home Manager's starship to prevent configuration conflict with the `xdg.configFile."starship.toml".text`.
        # Instead, use home.pkgs for Starship other than `program.starship.enable`.
        starship = {
          enable = false;
        };

        zsh = {
          enable = true;
          dotDir = "${config.xdg.configHome}/zsh";

          # Completion, tracking, and suggestion features
          enableCompletion = false;
          enableVteIntegration = true;
          autosuggestion.enable = true;
          syntaxHighlighting.enable = true;

          initContent = ''
            # Speeding up Oh-My-ZSH - https://scottspence.com/posts/speeding-up-my-zsh-shell

              SPACESHIP_PROMPT_ASYNC=true
              ZSH_AUTOSUGGEST_USE_ASYNC=1

            # End of Speeding up Oh-My-ZSH

            # `fzf` provided via env.sysPkgs
            if [ -n "$\{commands[fzf-share]\}" ]; then
              source "$(fzf-share)/key-bindings.zsh"
              source "$(fzf-share)/completion.zsh"
            fi

            eval "$(starship init zsh)"
          '';

          history = {
            path = "${config.xdg.dataHome}/zsh/.zsh_history";

            # When browsing history via `Ctrl+R`, do not show a duplicate line again.
            findNoDups = true;

            # Excluding items to history
            ignoreAllDups = true;
            ignorePatterns = [
              "c"
              "cls"
              "clear"
              "history"
              "exit"
              "q"
              "pwd"
            ];
            saveNoDups = true;

            # Internal list and local save
            append = true;
            expireDuplicatesFirst = true;
            size = 500000;
            save = 500000;
          };

          oh-my-zsh = {
            enable = true;
            plugins = [
              "git"
              "fzf"
              "extract"
            ];
          };
        };
      };
    };

  flake.nixosModules.shell =
    { pkgs, ... }:
    {
      environment = {
        localBinInPath = true;

        pathsToLink = [
          "/share/zsh" # For Home Manager's programs.zsh.enableCompletion
        ];

        systemPackages = with pkgs; [
          git
          fzf
          libextractor
        ];
      };

      programs = {
        zsh = {
          enable = true;
          enableLsColors = true;
          enableCompletion = true;
          autosuggestions.enable = true;
          syntaxHighlighting.enable = true;

          shellInit = ''
            if [ -n "$\{commands[fzf-share]\}" ]; then
              source "$(fzf-share)/key-bindings.zsh"
              source "$(fzf-share)/completion.zsh"
            fi
          '';

          histSize = 100000;
          histFile = "$HOME/.zsh_history";

          ohMyZsh = {
            enable = true;
            plugins = [
              "git"
              "fzf"
              "extract"
            ];
          };
        };
      };
    };
}
