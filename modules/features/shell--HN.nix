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

          # TODO: Perhaps move this to a more user-centric configuration. Currently serves `livresonata`.
          shellAliases = {
            backupUploadGDrive = ''
              echo -n "Enter rclone config password: "
              read -s pass
              echo

              RCLONE_CONFIG_PASS=$pass rclone sync "$HOME/Documents/Artwork Projects" "gdrive-artwork:Backups/Artwork Projects" --check-first --track-renames --update --create-empty-src-dirs -MvP --drive-skip-gdocs --fix-case &&
              RCLONE_CONFIG_PASS=$pass rclone sync "$HOME/Documents/Work" "gdrive-artwork:Backups/Work" --check-first --track-renames --update --create-empty-src-dirs -MvP --drive-skip-gdocs --fix-case &&

              unset pass
              echo "Backup upload complete"
            '';

            clrKFXtemp = ''
              echo "Clearing Kindle Previewer temporary files..."
              rm -rf "/home/livresonata/.wine/drive_c/users/livresonata/AppData/Local/Temp" && echo "Sucessfully cleared temp files!"
            '';

            cls = ''
              clear
            '';

            whatAppEject = ''
              sudo lsof $1
            '';

            wss = ''
              setsid waydroid session start >/dev/null 2>&1
              setsid waydroid show-full-ui >/dev/null 2>&1
              echo "[shell] Waydroid session started with showing full user interface"
            '';

            wsx = ''
              waydroid session stop && echo "[shell] Waydroid session has been closed"
            '';

            wsu = ''
              sudo waydroid upgrade || return 1
              echo -e "\n[shell] Requesting root access for service restart"
              notify-send -u critical "Waydroid Upgrade" "Requesting root access for service restart"
              sudo systemctl restart waydroid-container.service || echo "[shell] Restart failed"
            '';

            yth264 = ''
              yt-dlp \
                --format "bestvideo[ext=mp4]+bestaudio[ext=m4a]" \
                --format-sort "vcodec:h264" \
                --downloader aria2c \
                --no-embed-thumbnail \
                --no-post-overwrites \
                --no-write-description \
                --no-write-info-json \
                "$@"
            '';
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
