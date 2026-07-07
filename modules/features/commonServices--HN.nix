{ ... }:

{
  flake.homeModules.commonServices =
    { config, ... }:
    {
      services = {
        arrpc.enable = false; # For Nixcord when using custom clients.
        mpd-mpris.enable = true;

        mpd = {
          enable = true;
          playlistDirectory = "${config.xdg.userDirs.music}/Playlist/MPD";

          extraConfig = ''
            auto_update "yes"

            audio_output {
              type "pipewire"
              name "PipeWire output"
            }
          '';

          network = {
            port = 6600;
            listenAddress = "127.0.0.1";
            startWhenNeeded = true;
          };
        };
      };

      xdg.configFile."mpd/mpd.conf" = {
        enable = config.services.mpd.enable;
        text = config.services.mpd.generatedConfig;
      };
    };

  flake.nixosModules.commonServices =
    { ... }:
    {
      services = {
        kmscon.enable = true;
        smartd.enable = true;
        udisks2.enable = true;
        printing.enable = true;
        ddccontrol.enable = true;
      };
    };
}
