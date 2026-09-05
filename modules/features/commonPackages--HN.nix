{ ... }:

{
  flake.homeModules.commonPackages =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        # CLI
        ffmpeg-full

        # Language Server Protocol
        nil # Nix LSP by oxalica
        nixd # Nix LSP by nix-community
        nixfmt

        # Multimedia
        vlc
        rmpc # Requires `services.mpd.enable`.
        calibre
        qpwgraph
        webcamoid

        # Office
        libreoffice-qt-stable

        # Programming Languages
        python314

        # Spelling Library
        harper
        hunspell
        hunspellDicts.en_AU
        hunspellDicts.en_US
        hunspellDicts.en_GB-ise

        # Terminal Emulator
        kitty
        kitty-img
        kitty-themes

        # Utilities
        kcc
        scrcpy
        qbittorrent
        showmethekey
        nixpkgs-track
      ];
    };

  flake.nixosModules.commonPackages =
    { config, pkgs, ... }:
    {
      environment.systemPackages =
        with pkgs;
        [
          # Wayland
          wl-clipboard
          wayland-utils

          # Archival Utilities
          zip
          lzip
          p7zip
          unrar
          unzip

          # CLI Binaries
          dig
          fzf
          sops
          whois
          rclone
          psmisc
          ddcutil
          usbutils
          pciutils
          fastfetch
          inetutils
          alsa-utils
          lm_sensors
          traceroute
          vulkan-tools
          android-tools
          smartmontools

          # Libraries
          libnotify
          libva-utils

          # Utilities
          kdePackages.filelight
          kdePackages.partitionmanager

          # FHS-compliant Launcher
          steam-run
        ]
        # Add more GPU conditionals if more are added in `./hardware`.
        ++ lib.optionals (!config.hardware.amdgpu.enable) [
          # TUI System Monitoring
          btop
          nvtop
        ];
    };
}
