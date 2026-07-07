{ ... }:

{
  flake.nixosModules.pwQuantum =
    { ... }:
    {
      # Attempt at minimizing audio crackles
      # Formulas: ( Quantum / Sampling Rate ) * 1000 = Latency in Milliseconds
      #           ( 1000ms / Refresh Rate or Hz or FPS ) * ( Sampling Rate / 1000 ) = Quantum
      #
      # Value for Sampling Rate is set to 48kHz for this configuration.
      #
      # References: 20ms or lower is better
      #             1000ms / 60Hz or FPS = 16.67ms = 800 Quantum
      #             All Wine instances use minimum quantum.
      #
      # Command to see sample rates: `grep -E 'Codec|Audio Output|rates' /proc/asound/card*/codec#*`
      #
      # Guides: https://forum.endeavouros.com/t/pipewire-guide-audio-crackling-popping-and-latency/69602
      #         https://www.reddit.com/r/linux_gaming/comments/1gao420/low_latency_guide_for_linux_using_pipewire/

      services.pipewire.extraConfig = {
        pipewire = {
          "10-crackle-tweak-pw" = {
            "context.properties" = {
              "default.clock.rate" = 48000;
              "default.clock.allowed-rates" = [
                44100
                48000
              ];
              "default.clock.quantum" = 1024; # 21.33ms
              "default.clock.min-quantum" = 800; # 16.67ms
              "default.clock.max-quantum" = 4096; # 85.33ms
            };
          };
        };

        pipewire-pulse = {
          "10-crackle-tweak-pulse" = {
            "context.properties" = [
              {
                name = "libpipewire-module-protocol-pulse";
                args = {
                  "nice.level" = -20;
                  "rt.prio" = 99;
                };
              }
            ];

            "pulse.properties" = {
              "pulse.min.req" = "800/48000"; # 16.67ms
              "pulse.default.req" = "1024/48000"; # 21.33ms
              "pulse.max.req" = "4096/48000"; # 85.33ms
              "pulse.min.quantum" = "800/48000"; # 16.67ms
              "pulse.max.quantum" = "4096/48000"; # 85.33ms
            };
          };
        };

        jack = {
          "10-crackle-tweak-jack" = {
            "jack.properties" = {
              "node.latency" = "1024/48000"; # 21.33ms
              "node.quantum" = "1024/48000"; # 21.33ms
            };
          };
        };
      };
    };
}
