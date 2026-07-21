{ ... }:

{
  flake.homeModules.gaming =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        # Emulators
        mesen
        ppsspp
        melonds

        # Games
        gzdoom
        celeste64
        (starsector.overrideAttrs (
          { ... }:
          {
            # Note: Reduce memory if possible or manage mods to not risk reaching 6-8GiB.
            postInstall = ''
              substituteInPlace $out/share/starsector/data/config/settings.json \
                --replace-fail "\"maxBattleSize\":400," "\"maxBattleSize\":2000," \
                --replace-fail "\"doRAMandVRAMChecksWhenRunningWithMods\":true," "\"doRAMandVRAMChecksWhenRunningWithMods\":false,"

              substituteInPlace $out/share/starsector/.starsector.sh-wrapped \
                --replace-fail "-Xms2048m" "-Xms6144m" \
                --replace-fail "-Xmx2048m" "-Xmx6144m"
            '';
          }
        ))

        # Game Launchers
        heroic

        # Game Utilities
        olympus # Celeste Mod Manager
        mangojuice # MangoHud GUI Config

        # Utilities
        mangohud
      ];
    };

  flake.nixosModules.gaming =
    {
      packages,
      pkgs,
      ...
    }:
    {
      boot.kernelModules = [ "ntsync" ];

      environment.sessionVariables = {
        # AMD FSR for GE-Proton
        ## Disable auto-FSR in Proton-GE and driv; Enable manually in launch params with other options.
        ## Opts: WINE_FULLSCREEN_FSR = 2; WINE_FULLSCREEN_MODE = "balanced"; WINE_FULLSCREEN_CUSTOM_MODE = "1152x648";
        ## See: https://github.com/GloriousEggroll/proton-ge-custom?tab=readme-ov-file#options
        WINE_FULLSCREEN_FSR = 0;

        # DXVK with GPLASync/Async Support for performance speedup
        ## Should not be used with anti-cheat games. Use with caution.
        ## See: https://dawn.wine/dawn-winery/dwproton/src/branch/main/docs/DXVK.md
        DXVK_ASYNC = 0;
        PROTON_DXVK_GPLASYNC = 0; # May require custom Proton (e.g. dwproton); Cannot be with LOWLATENCY, use LLASYNC instead.

        # dwproton - Dawn Winery's patched envvars
        ## See: https://dawn.wine/dawn-winery/dwproton#new-environmental-variables
        WINE_USE_TAKE_FOCUS = 1;
        PROTON_DXVK_LLASYNC = 0; # Enables both GPLASYNC and LOWLATENCY features; GPLASYNC may trigger anti-cheat.
        PROTON_MAP_SYSCALLS = 0;
        PROTON_USE_WINEALSA = 0;
        WINE_CANONICAL_HOLE = "skip_volatile_check"; # 'Special' env; Unsure what it does, but claims performance boost.
        PROTON_DXVK_LOWLATENCY = 1;

        # NTSYNC - Proton
        ## Must enable 'ntsync' module to work.
        PROTON_NO_NTSYNC = 0; # Legacy parameter. Kept for older Proton variants.
        PROTON_USE_WOW64 = 0; # Can crash some games and trigger anti-cheat, but must be on for 32-bit.
        PROTON_USE_NTSYNC = 1;

        # Proton Wayland
        PROTON_ENABLE_WAYLAND = 0;
      };

      programs = {
        gamescope = {
          enable = true;
          capSysNice = false;
        };

        steam = {
          enable = true;
          extest.enable = true;
          protontricks.enable = false; # Use Flatpak version and implicitly add folder permissions.
          remotePlay.openFirewall = true; # Steam Remote Play
          dedicatedServer.openFirewall = true; # Source Dedicated Server
          localNetworkGameTransfers.openFirewall = true; # Steam Local Network Game Transfers

          extraCompatPackages = with pkgs; [
            proton-ge-bin
            packages.dwproton
          ];
        };
      };
    };
}
