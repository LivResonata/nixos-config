{ ... }:

{
  flake.homeModules.editor =
    { pkgs, ... }:
    let
      extraEditorPackages = with pkgs; [
        # CSS
        vscode-css-languageserver

        # JSON
        jq
        vscode-json-languageserver

        # Language & Grammar
        harper

        # KDL
        kdlfmt

        # Lua
        lua-language-server

        # Python3
        ruff
        python314

        # Nix Language
        nil
        nixd
        nixfmt
        nixfmt-tree # For use in projects or use the flake formatter.

        # Markdown
        markdown-oxide

        # TOML
        tombi

        # YAML
        yamlfmt
        yaml-language-server

        # Misc
        prettier
        package-version-server
      ];
    in
    {
      home.packages =
        with pkgs;
        [
          # Globally in $PATH.
          ## Language Server Protocols
          nil
          nixd
          nixfmt
          nixfmt-tree # For use in projects or use the flake formatter.
        ]
        ++ [
          # Equivalent to Home Manager programs.helix.extraPackages.
          ## Creating it here avoids using the Home Manager module that
          ##  will conflcit with imperative setups.
          (pkgs.symlinkJoin {
            name = "helix";
            paths = [ pkgs.helix_git ];
            preferLocalBuild = true;
            nativeBuildInputs = [ pkgs.makeWrapper ];
            postBuild = ''
              wrapProgram $out/bin/hx \
                --suffix PATH : ${lib.makeBinPath extraEditorPackages}
            '';
          })
        ];

      programs.zed-editor = {
        enable = true;

        extensions = [
          # Language Support (without server)
          "kdl"
          "lua"
          "nix"
          "html"
          "toml"
          "json5"
          "caddyfile"
          "dockerfile"

          # Language Server
          "tombi"
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

        extraPackages = extraEditorPackages;

        # Allow Zed to update the configuration files
        ## Is set to `true` by default.
        mutableUserDebug = true;
        mutableUserTasks = true;
        mutableUserKeymaps = true;
        mutableUserSettings = true;
      };
    };

  flake.nixosModules.editor =
    { pkgs, ... }:
    {
      environment = {
        systemPackages = with pkgs; [ helix ]; # Use stable Helix instead of pkgs.helix_git.

        sessionVariables = {
          # Default CLI text editor.
          ## Set the value with the binary of the program.
          EDITOR = "hx";
          SUDO_EDITOR = "hx";
        };
      };

      programs.neovim = {
        enable = true;
        defaultEditor = false;
      };
    };
}
