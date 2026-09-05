{
  self,
  inputs,
  ...
}:

{
  flake.homeModules.livresonata =
    {
      osConfig,
      lib,
      ...
    }:
    {
      # Modular Configuration
      imports = with self.homeModules; [
        # Features
        ## In order of ascending folder-file names.
        theming # folder: theming
        browsers
        commonPackages
        commonPrograms
        commonServices
        editor
        flatpak
        gaming
        git
        graphics
        inputMethod
        shell
        ssh
      ];

      # Non-modular Configuration
      ## Custom module options
      #theming.preset = "everforest-dark-medium";

      ## Standard options
      home = {
        username = "livresonata";
        homeDirectory = "/home/livresonata";
      };

      programs.zsh.shellAliases = lib.mkMerge [
        {
          backupUploadGDrive = ''
            echo -n "Enter rclone config password: "
            read -s pass
            echo

            RCLONE_CONFIG_PASS=$pass rclone sync "$HOME/Documents/Work" "gdrive-artwork:Backups/Work" --check-first --track-renames --update --create-empty-src-dirs -MvP --drive-skip-gdocs --fix-case &&

            # Temporarily Disabled
            #RCLONE_CONFIG_PASS=$pass rclone sync "$HOME/Documents/Artwork Projects" "gdrive-artwork:Backups/Artwork Projects" --check-first --track-renames --update --create-empty-src-dirs -MvP --drive-skip-gdocs --fix-case &&

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
        }

        (lib.mkIf osConfig.virtualisation.waydroid.enable {
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
        })
      ];

      services.flatpak.extraCategories = [
        "audio"
        "gaming"
        "graphics"
        "noctalia"
        "sensitives"
      ];

      xdg = {
        enable = true;

        userDirs = {
          enable = true;
          createDirectories = true;
          setSessionVariables = false;

          # Move to external HDD for media files
          music = if osConfig.networking.hostName == "flos" then "/media/Iris/livresonata/Music" else null;
          pictures =
            if osConfig.networking.hostName == "flos" then "/media/Iris/livresonata/Pictures" else null;
        };
      };

      # HM 26.05 default. Legacy had `config.gtk.theme`.
      gtk.gtk4.theme = lib.mkDefault null;

      # Let Home Manager install and manage itself.
      programs.home-manager.enable = true;

      # This value determines the Home Manager release that your configuration is
      # compatible with. This helps avoid breakage when a new Home Manager release
      # introduces backwards incompatible changes.
      #
      # You should not change this value, even if you update Home Manager. If you do
      # want to update the value, then make sure to first check the Home Manager
      # release notes.
      home.stateVersion = "25.05"; # Please read the comment before changing.
    };

  flake.nixosModules.livresonata =
    {
      config,
      pkgs,
      ...
    }:
    {
      imports = [
        inputs.home-manager.nixosModules.default
      ];

      users = {
        mutableUsers = false;

        users.livresonata = {
          shell = if config.programs.zsh.enable then pkgs.zsh else pkgs.bash;
          isNormalUser = true;
          description = "Liv Resonata";
          hashedPasswordFile = config.sops.secrets.password-livresonata.path;
          group = "wheel";
          extraGroups = [
            "networkmanager"
            "i2c"
            "realtime"
            "public"
            "libvirtd"
            "kvm"
            "adbusers"
          ];
        };
      };

      home-manager = {
        # TODO: Remove useGlobalPkgs and useUserPackages when `true` by default.
        useGlobalPkgs = true;
        useUserPackages = true;
        users.livresonata = self.homeModules.livresonata;
      };

      time.timeZone = "Asia/Manila";
      i18n = {
        defaultLocale = "en_PH.UTF-8";

        extraLocaleSettings = {
          LC_ADDRESS = "fil_PH";
          LC_IDENTIFICATION = "fil_PH";
          LC_MEASUREMENT = "fil_PH";
          LC_MONETARY = "fil_PH";
          LC_NAME = "fil_PH";
          LC_NUMERIC = "fil_PH";
          LC_PAPER = "fil_PH";
          LC_TELEPHONE = "fil_PH";
          LC_TIME = "fil_PH";
        };
      };
    };
}
