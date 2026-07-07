{ self, inputs, ... }:

{
  flake.homeModules.theming =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      imports = with self.homeModules; [
        themingPresets
        inputs.stylix.homeModules.stylix
      ];

      home.packages = with pkgs; [
        ## Generalized
        kdePackages.breeze
        kdePackages.breeze-icons

        ## Cursor
        posy-cursors
        rose-pine-cursor

        ## Icon Pack
        adwaita-icon-theme
        adwaita-icon-theme-legacy
        papirus-icon-theme
      ];

      stylix = {
        enable = lib.mkDefault false;
        autoEnable = true;

        # Required for Home Manager due to an evaluation warning if home-manager.useGlobalPkgs is set to 'true'.
        ## See: https://github.com/nix-community/stylix/issues/1832
        overlays.enable = false;

        fonts = {
          sizes = {
            # Unit of measurement is in 'pt'
            applications = 10;
            desktop = 10;
            terminal = 10;
          };
        };

        targets = {
          # Disabled targets
          ## Discord
          nixcord.enable = false;
          vencord.enable = false;
          vesktop.enable = false;

          ## GTKSourceView
          ### Forces rebuilds of some GTK apps (e.g. Inkscape)
          gtksourceview.enable = false;

          ## KDE
          kde.enable = false;

          ## Neovim, Neovide, NixVim, nvf, and Vim
          neovide.enable = false;
          neovim.enable = false;
          nixvim.enable = false;
          nvf.enable = false;
          vim.enable = false;

          # Noctalia Shell
          noctalia-shell.enable = false;

          ## Zed
          zed.enable = false;

          ## Zen Browser
          ### Requires declarative profiles; else will conflict with implicit `profiles.ini`
          zen-browser.enable = false;
        };
      };

      # XDG - Local-Share Dotfiles
      xdg.configFile = lib.mkIf config.stylix.enable {
        # Prioritize rebuilds by overwriting implicit configs by KDE Plasma or GTK Theming.
        "gtk-3.0/gtk.css".force = true;
        "gtk-3.0/settings.ini".force = true;
        "gtk-4.0/gtk.css".force = true;
        "gtk-4.0/settings.ini".force = true;
      };

      # Continuation of prioritizing rebuilds over implicit configs along with GTK3/4 via XDG configFile force.
      gtk.gtk2.force = if config.stylix.enable then true else false;
    };
}
