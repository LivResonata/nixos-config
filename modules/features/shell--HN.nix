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
          fzf
          starship
        ];

        programs = {
          # Disable Home Manager's starship to prevent configuration conflict with the `xdg.configFile."starship.toml".text`.
          # Instead, use home.packagess for Starship other than `program.starship.enable`.
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

              /*
                Common order values for `lib.mkOrder`:
                - 500 (mkBefore): Early initialization
                - 550: Before completion initialization
                - 1000 (default): General configuration
                - 1500 (mkAfter): Last to run configuration
              */
              initContent = lib.mkMerge [
                (lib.mkOrder 500 ''
                  # Debugging Performance - Profiling code injection (Step 01 of 02)
                  ## See: https://gist.github.com/elalemanyo/cb3395af64ac23df2e0c3ded8bd63b2f
                  ##      https://www.dotruby.com/articles/profiling-zsh-setup-with-zprof
                  if [[ -n "$ZSH_DEBUGRC" ]]; then
                    zmodload zsh/zprof
                  fi
                '')

                # General Configuration
                ''
                  SPACESHIP_PROMPT_ASYNC=true
                  ZSH_AUTOSUGGEST_USE_ASYNC=1

                  # `fzf` provided via env.sysPkgs
                  if [ -n "''${commands[fzf]}" ]; then
                    source <(fzf --zsh)
                  fi

                  eval "$(starship init zsh)"
                ''

                (lib.mkOrder 2000 ''
                  # Debugging Performance - Display results (Step 02 of 02)
                  ## See: https://gist.github.com/elalemanyo/cb3395af64ac23df2e0c3ded8bd63b2f
                  ##      https://www.dotruby.com/articles/profiling-zsh-setup-with-zprof
                  if [[ -n "$ZSH_DEBUGRC" ]]; then
                    zprof
                  fi
                '')
              ];

              history = {
                path = "${config.xdg.dataHome}/zsh/.zsh_history";

                # When browsing history via the `history` command, do not show a duplicate line again.
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
                size = 100000;
                save = 100000;
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
                (lib.mkIf config.programs.zsh.autosuggestion.enable (
                  lib.mkOrder 1501 ''
                    ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(
                      zhm_history_prev
                      zhm_history_next
                      zhm_prompt_accept
                      zhm_accept
                      zhm_accept_or_insert_newline
                    )

                    ZSH_AUTOSUGGEST_ACCEPT_WIDGETS+=(
                      zhm_move_right
                      zhm_clear_selection_move_right
                    )

                    ZSH_AUTOSUGGEST_PARTIAL_ACCEPT_WIDGETS+=(
                      zhm_move_next_word_start
                      zhm_move_next_word_end
                    )
                  ''
                ))

                (lib.mkIf config.programs.zsh.syntaxHighlighting.enable (
                  lib.mkOrder 1502 ''
                    zhm-add-update-region-highlight-hook
                  ''
                ))

                (lib.mkIf
                  (
                    (lib.lists.any (param: lib.strings.hasInfix "fzf" param) config.home.packages)
                    || (
                      # For Oh-My-ZSH's fzf plugin.
                      config.programs.zsh.oh-my-zsh.enable
                      && (lib.lists.any (param: lib.strings.hasInfix "fzf" param) config.programs.zsh.oh-my-zsh.plugins)
                    )
                  )
                  (
                    lib.mkOrder 1503 ''
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
    { ... }:
    {
      environment = {
        localBinInPath = true;

        pathsToLink = [
          "/share/zsh" # For Home Manager's programs.zsh.enableCompletion
        ];
      };

      programs.zsh = {
        enable = true;
        enableLsColors = true;

        histSize = 100000;
        histFile = "$HOME/.zsh_history";
      };
    };
}
