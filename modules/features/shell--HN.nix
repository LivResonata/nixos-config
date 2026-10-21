{ inputs, ... }:

{
  flake.homeModules.shell =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.programs.zsh;
    in
    {
      options.programs.zsh = {
        zsh-helix-mode.enable = lib.mkEnableOption null // {
          default = false;
          example = true;
          description = ''
            Sets up zsh-helix-mode to have Helix keybindings and behavior in ZSH.
          '';
        };
      };

      config = {
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

          zsh = lib.mkMerge [
            {
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
            }

            (lib.mkIf cfg.zsh-helix-mode.enable {
              plugins = [
                {
                  name = "zsh-helix-mode";
                  # TODO: Find out how the repo's flake overlay works and perhaps present a fix?
                  src = inputs.zsh-helix-mode.packages.${pkgs.stdenv.hostPlatform.system}.default;
                  file = "share/zsh-helix-mode/zsh-helix-mode.plugin.zsh";
                }
              ];

              initContent = lib.mkMerge [
                (lib.mkIf config.programs.zsh.syntaxHighlighting.enable (
                  lib.mkAfter ''
                    zhm-add-update-region-highlight-hook
                  ''
                ))

                (lib.mkIf
                  (lib.lists.any (param: lib.strings.hasInfix "fzf" param) config.programs.zsh.oh-my-zsh.plugins)
                  (
                    lib.mkAfter ''
                      zhm_wrap_widget fzf-completion zhm_fzf_completion
                      bindkey '^I' zhm_fzf_completion
                    ''
                  )
                )
              ];
            })
          ];
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

      programs.zsh = {
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
}
