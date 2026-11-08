{ self, ... }:

{
  flake.nixosModules.audio =
    {
      pkgs,
      ...
    }:
    {
      imports = with self.nixosModules; [
        virtSurround
      ];

      # Prevent audio device suspend.
      boot.extraModprobeConfig = ''
        options snd_hda_intel power_save=0
      '';

      environment.systemPackages = with pkgs; [
        pamixer
      ];

      # Realtime Privilege
      security.rtkit.enable = true;

      # ALSA Sound Card Persistence
      hardware.alsa.enablePersistence = true;

      # Pipewire Proper
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        pulse.enable = true;
        alsa.support32Bit = true;
        wireplumber.enable = true;

        extraConfig = {
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
        };

        wireplumber.extraConfig = {
          # Do not suspend nodes when inactive
          ## See: https://wiki.archlinux.org/title/PipeWire#Noticeable_audio_delay_or_audible_pop/crack_when_starting_playback
          ##      https://wiki.nixos.org/wiki/PipeWire#Sound_pops_a_few_seconds_after_playback_stops_OR_audio_takes_a_long_time_to_start_playing_after_a_couple_of_seconds
          "98-disable-suspension" = {
            "monitor.alsa.rules" = [
              {
                matches = [
                  {
                    "node.name" = "~alsa_input.*";
                  }

                  {
                    "node.name" = "~alsa_output.*";
                  }
                ];

                actions = {
                  update-props = {
                    "session.suspend-timeout-seconds" = 0;
                  };
                };
              }
            ];

            ## Disable Bluetooth suspension in case of active use in future setups
            "monitor.bluez.rules" = [
              {
                matches = [
                  {
                    "node.name" = "~bluez_input.*";
                  }

                  {
                    "node.name" = "~bluez_output.*";
                  }
                ];

                actions = {
                  update-props = {
                    "session.suspend-timeout-seconds" = 0;
                  };
                };
              }
            ];
          };

          # Ignore hardware mixer volume control
          ## Fifine AM8 PC volume fires at 50% Pipewire vol.
          ## See: https://wiki.archlinux.org/title/PipeWire#No_sound_from_USB_DAC_until_30%_volume
          "99-alsa-soft-mixer" = {
            "monitor.alsa.rules" = [
              {
                matches = [
                  {
                    "device.name" = "alsa_card.usb-MV-SILICON_fifine_Microphone_20190808-00";
                  }
                ];

                actions = {
                  update-props = {
                    "api.alsa.soft-mixer" = true;
                  };
                };
              }
            ];
          };
        };
      };
    };
}
