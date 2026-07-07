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
        mpd-mpris
        webcamoid

        # Office
        libreoffice-qt6-fresh

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
        wineWow64Packages.stable
      ];
    };

  flake.nixosModules.commonPackages =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        # Wayland
        wl-clipboard
        wayland-utils

        # Archival Utilities
        zip
        lzip
        pzip
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

        # TUI System Monitoring
        btop-rocm
        nvtopPackages.amd

        # Utilities
        kdePackages.filelight
        kdePackages.partitionmanager

        # FHS-compliant Launcher
        steam-run
      ];
    };
}
