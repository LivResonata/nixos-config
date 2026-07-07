{ ... }:

{
  flake.homeModules.editor =
    { pkgs, ... }:
    {
      home.sessionVariables = {
        # Neovim Editor
        ## Forgot where, but there was a mention of programs.neovim.defaultEditor not working.
        EDITOR = "nvim";
      };

      programs = {
        neovim = {
          enable = true;
          defaultEditor = true;

          # Legacy option had `true`; New default is `false`.
          withRuby = false;
          withPython3 = false;

          # Includes modified delete and yanking keybinds
          ## See: https://github.com/pazams/d-is-for-delete?tab=readme-ov-file
          extraConfig = ''
            syntax on

            nnoremap <SPACE> <Nop>
            let mapleader= " "

            set wrap
            set number
            set linebreak
            set relativenumber
            set mouse=
            set tabstop=2
            set shiftwidth=2

            nnoremap x "_x
            nnoremap X "_X
            nnoremap d "_d
            nnoremap D "_D
            vnoremap d "_d

            if has('unnamedplus')
              set clipboard=unnamed,unnamedplus
              nnoremap <leader>d "+d
              nnoremap <leader>D "+D
              vnoremap <leader>d "+d
            else
              set clipboard=unnamed
              nnoremap <leader>d "*d
              nnoremap <leader>D "*D
              vnoremap <leader>d "*d
            endif
          '';
        };

        zed-editor = {
          enable = true;

          extensions = [
            # Language Support (w/o Server)
            "kdl"
            "lua"
            "nix"
            "html"
            "toml"
            "json5"
            "caddyfile"
            "dockerfile"

            # Language Server
            "harper"
            "markdown-oxide"

            # Syntax Highlighting
            "comment"
            "docker-compose"

            # Theming
            "catppuccin"
            "rose-pine-theme"
            "catppuccin-icons"
          ];

          extraPackages = with pkgs; [
            # Python3
            ruff
            python314

            # Nix Language
            nil
            nixd
            nixfmt

            # Markdown
            markdown-oxide

            # Misc
            prettier
            package-version-server
          ];

          # Allow Zed to update the configuration files
          ## Is set to `true` by default.
          mutableUserDebug = true;
          mutableUserTasks = true;
          mutableUserKeymaps = true;
          mutableUserSettings = true;
        };
      };
    };

  flake.nixosModules.editor =
    { ... }:
    {
      programs.neovim = {
        enable = true;
        defaultEditor = true;

        # Includes modified delete and yanking keybinds
        ## See: https://github.com/pazams/d-is-for-delete?tab=readme-ov-file
        configure = {
          customRC = ''
            syntax on

            nnoremap <SPACE> <Nop>
            let mapleader= " "

            set wrap
            set number
            set linebreak
            set relativenumber
            set mouse=
            set tabstop=2
            set shiftwidth=2

            nnoremap x "_x
            nnoremap X "_X
            nnoremap d "_d
            nnoremap D "_D
            vnoremap d "_d

            if has('unnamedplus')
              set clipboard=unnamed,unnamedplus
              nnoremap <leader>d "+d
              nnoremap <leader>D "+D
              vnoremap <leader>d "+d
            else
              set clipboard=unnamed
              nnoremap <leader>d "*d
              nnoremap <leader>D "*D
              vnoremap <leader>d "*d
            endif
          '';
        };
      };
    };
}
