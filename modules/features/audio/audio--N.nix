{ self, ... }:

{
  flake.nixosModules.audio =
    {
      pkgs,
      ...
    }:
    {
      imports = with self.nixosModules; [
        pwQuantum
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
        jack.enable = true;
        pulse.enable = true;
        alsa.support32Bit = true;
        wireplumber.enable = true;

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
