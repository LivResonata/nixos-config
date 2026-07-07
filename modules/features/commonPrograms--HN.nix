{ inputs, ... }:

{
  flake.homeModules.commonPrograms =
    { osConfig, pkgs, ... }:
    {
      imports = [
        inputs.nixcord.homeModules.nixcord
      ];

      programs = {
        obsidian.enable = true;

        mpv = {
          enable = true;
          package = pkgs.mpv;

          config = {
            # Profile to load and is listed via `--profile=help`
            profile = "high-quality";

            # Fullscreen and window geometry
            fs = "yes";
            geometry = "50%:50%";
            autofit-larger = "75%x75%";

            # GPU/GPUNEXT and GPU API
            vo = "gpu-next";
            gpu-api = "vulkan";

            # Hardware acceleration
            hwdec = "vulkan";

            # Default audio device and type
            ao = "pulse";
            audio-device = "pulse/easyeffects_sink"; # Requires EasyEffects via NixOS or Flatpak

            # Volume
            volume = 125;
            volume-max = 175.0;

            # Local RAM cache for seeking
            cache = "yes";

            # Audio
            alang = "ja,en";
            audio-display = "no";

            # Subtitles
            slang = "en";
            sub-scale = "0.7";

            # On-screen Display
            ## Temporary fix for default Noto Sans font not found.
            ## Possible related issue: https://github.com/NixOS/nixpkgs/issues/527373
            osd-font = "Adwaita Sans";
          };

          extraInput = ''
            # Toggle hardware decoding options
            ctrl+h cycle-values hwdec "no" "vulkan"
          '';

          scripts = with pkgs; [
            mpvScripts.mpris
          ];
        };

        nixcord = {
          # Documentation and Options
          # See: https://flameflag.github.io/nixcord/

          enable = true;
          dorion.enable = false; # WebRTC via WebkitGTK is not supported yet

          config = {
            frameless = true;
            transparent = false;

            enabledThemes =
              if osConfig.programs.niri.enable then
                [
                  "noctalia-material.theme.css"
                ]
              else
                [ ];

            plugins = {
              # Vencord Plugins
              ## Required
              webContextMenus.enable = true;

              ## User Additions
              ### Lower Case
              fakeNitro.enable = true;
              fixImagesQuality.enable = true;
              imageFilename.enable = true;
              previewMessage.enable = true;
              quickMention.enable = true;
              voiceDownload.enable = true;
              webKeybinds.enable = true;
              webScreenShareFixes.enable = true;
              youtubeAdblock.enable = true;
              ### Upper Case
              clearUrls.enable = true;

              memberCount = {
                enable = true;
                memberList = true;
                toolTip = false;
              };

              platformIndicators = {
                enable = true;
                colorMobileIndicator = true;
                list = true;
                messages = false;
              };

              showHiddenThings = {
                enable = true;
              };

              voiceMessages = {
                enable = true;
                echoCancellation = false;
                noiseSuppression = false;
              };

              volumeBooster = {
                enable = true;
                multiplier = 2.0;
              };
            };
          };

          discord = {
            enable = true;
            branch = "stable"; # stable, ptb, canary, development
            vencord.enable = true;
            openASAR.enable = false;
            commandLineArgs = [ "--enable-blink-features=MiddleClickAutoscroll" ];
          };
        };

        obs-studio = {
          enable = true;
          plugins = with pkgs.obs-studio-plugins; [
            obs-backgroundremoval
          ];
        };

        yazi = {
          enable = true;
          shellWrapperName = "y";
          enableZshIntegration = true;
          enableBashIntegration = true;

          extraPackages = with pkgs; [
            file
            ffmpeg
            p7zip
            jq
            poppler
            fd
            ripgrep
            fzf
            zoxide
            resvg
            imagemagick
            wl-clipboard
          ];
        };
      };
    };

  flake.nixosModules.commonPrograms =
    { ... }:
    {
      programs = {
        # Enabled
        java.enable = true;
        iotop.enable = true;
        kdeconnect.enable = true;
        thunderbird.enable = true;
        partition-manager.enable = true;

        appimage = {
          enable = true;
          binfmt = true;
        };

        nh = {
          enable = true;
          flake = "/etc/nixos"; # Implicit symlink to userland git folder for `LivResonata/nixos-config`

          clean = {
            enable = true;
            dates = "daily";
            extraArgs = "--keep-since 5d";
          };
        };
      };
    };
}
