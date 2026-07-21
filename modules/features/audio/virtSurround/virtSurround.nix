{ ... }:

{
  flake.nixosModules.virtSurround =
    { config, lib, ... }:
    let
      cfg = config.services.pipewire.virtSurround;

      cfgSofaSource = "/etc/nixos/hosts/flos/pipewire/spatializer-virt-surround/SADIE_KU-100.sofa";
      cfgSofaSymlink = "/etc/pipewire-hrtf/Spatializer/SADIE_KU-100.sofa";
      cfgSofaGain = 0; # This depends on the .sofa file in use. Better left alone unless you know what to do, 'cuz I don't.
      cfgMixLRGain = 0.3; # Controls all mixers. Value `0.1` - `1.0`, less for quiet. Easier to predict.
    in
    {
      options.services.pipewire.virtSurround = {
        enable = lib.mkEnableOption null // {
          default = false;
          example = true;
          description = ''
            Whether to enable virtual surround via SADIE KU-100 spatializer.
          '';
        };
      };

      config = lib.mkIf cfg.enable {
        environment.etc."pipewire-hrtf/Spatializer/SADIE_KU-100.sofa" = {
          # Sofa File
          ## See: https://airtable.com/appayGNkn3nSuXkaz/shruimhjdSakUPg2m/tbloLjoZKWJDnLtTc
          source = cfgSofaSymlink;
          mode = "symlink";
        };

        services.pipewire.extraConfig.pipewire = {
          "20-spatializer-virt-surround" = {
            # Spatializer Sink
            ## See: https://gitlab.freedesktop.org/pipewire/pipewire/-/blob/master/src/daemon/filter-chain/spatializer-single.conf
            ##      https://gitlab.freedesktop.org/pipewire/pipewire/-/wikis/Filter-Chain

            "context.modules" = [
              {
                name = "libpipewire-module-filter-chain";
                flags = [ "nofail" ];

                args = {
                  "node.description" = "Spatial Virt-Surround Sink";
                  "media.name" = "Spatial Virt-Surround Sink";

                  "filter.graph" = {
                    nodes = [
                      {
                        type = "sofa";
                        label = "spatializer";
                        name = "spFL";
                        config = {
                          filename = cfgSofaSource;
                          gain = cfgSofaGain;
                        };
                        control = {
                          "Azimuth" = 30.0;
                          "Elevation" = 0.0;
                          "Radius" = 3.0;
                        };
                      }
                      {
                        type = "sofa";
                        label = "spatializer";
                        name = "spFR";
                        config = {
                          filename = cfgSofaSource;
                          gain = cfgSofaGain;
                        };
                        control = {
                          "Azimuth" = 330.0;
                          "Elevation" = 0.0;
                          "Radius" = 3.0;
                        };
                      }
                      {
                        type = "sofa";
                        label = "spatializer";
                        name = "spFC";
                        config = {
                          filename = cfgSofaSource;
                          gain = cfgSofaGain;
                        };
                        control = {
                          "Azimuth" = 0.0;
                          "Elevation" = 0.0;
                          "Radius" = 3.0;
                        };
                      }
                      {
                        type = "sofa";
                        label = "spatializer";
                        name = "spRL";
                        config = {
                          filename = cfgSofaSource;
                          gain = cfgSofaGain;
                        };
                        control = {
                          "Azimuth" = 150.0;
                          "Elevation" = 0.0;
                          "Radius" = 3.0;
                        };
                      }
                      {
                        type = "sofa";
                        label = "spatializer";
                        name = "spRR";
                        config = {
                          filename = cfgSofaSource;
                          gain = cfgSofaGain;
                        };
                        control = {
                          "Azimuth" = 210.0;
                          "Elevation" = 0.0;
                          "Radius" = 3.0;
                        };
                      }
                      {
                        type = "sofa";
                        label = "spatializer";
                        name = "spSL";
                        config = {
                          filename = cfgSofaSource;
                          gain = cfgSofaGain;
                        };
                        control = {
                          "Azimuth" = 90.0;
                          "Elevation" = 0.0;
                          "Radius" = 3.0;
                        };
                      }
                      {
                        type = "sofa";
                        label = "spatializer";
                        name = "spSR";
                        config = {
                          filename = cfgSofaSource;
                          gain = cfgSofaGain;
                        };
                        control = {
                          "Azimuth" = 270.0;
                          "Elevation" = 0.0;
                          "Radius" = 3.0;
                        };
                      }
                      {
                        type = "sofa";
                        label = "spatializer";
                        name = "spLFE";
                        config = {
                          filename = cfgSofaSource;
                          gain = cfgSofaGain;
                        };
                        control = {
                          "Azimuth" = 0.0;
                          "Elevation" = -60.0;
                          "Radius" = 3.0;
                        };
                      }

                      # Stereo Output
                      {
                        type = "builtin";
                        label = "mixer";
                        name = "mixL";
                        control = {
                          scale = "linear";
                          # Set individual left mixer gain if needed
                          "Gain 1" = cfgMixLRGain;
                          "Gain 2" = cfgMixLRGain;
                          "Gain 3" = cfgMixLRGain;
                          "Gain 4" = cfgMixLRGain;
                          "Gain 5" = cfgMixLRGain;
                          "Gain 6" = cfgMixLRGain;
                          "Gain 7" = cfgMixLRGain;
                          "Gain 8" = cfgMixLRGain;
                        };
                      }
                      {
                        type = "builtin";
                        label = "mixer";
                        name = "mixR";
                        control = {
                          scale = "linear";
                          # Set individual right mixer gain if needed
                          "Gain 1" = cfgMixLRGain;
                          "Gain 2" = cfgMixLRGain;
                          "Gain 3" = cfgMixLRGain;
                          "Gain 4" = cfgMixLRGain;
                          "Gain 5" = cfgMixLRGain;
                          "Gain 6" = cfgMixLRGain;
                          "Gain 7" = cfgMixLRGain;
                          "Gain 8" = cfgMixLRGain;
                        };
                      }
                    ];

                    links = [
                      {
                        output = "spFL:Out L";
                        input = "mixL:In 1";
                      }
                      {
                        output = "spFL:Out R";
                        input = "mixR:In 1";
                      }
                      {
                        output = "spFR:Out L";
                        input = "mixL:In 2";
                      }
                      {
                        output = "spFR:Out R";
                        input = "mixR:In 2";
                      }
                      {
                        output = "spFC:Out L";
                        input = "mixL:In 3";
                      }
                      {
                        output = "spFC:Out R";
                        input = "mixR:In 3";
                      }
                      {
                        output = "spRL:Out L";
                        input = "mixL:In 4";
                      }
                      {
                        output = "spRL:Out R";
                        input = "mixR:In 4";
                      }
                      {
                        output = "spRR:Out L";
                        input = "mixL:In 5";
                      }
                      {
                        output = "spRR:Out R";
                        input = "mixR:In 5";
                      }
                      {
                        output = "spSL:Out L";
                        input = "mixL:In 6";
                      }
                      {
                        output = "spSL:Out R";
                        input = "mixR:In 6";
                      }
                      {
                        output = "spSR:Out L";
                        input = "mixL:In 7";
                      }
                      {
                        output = "spSR:Out R";
                        input = "mixR:In 7";
                      }
                      {
                        output = "spLFE:Out L";
                        input = "mixL:In 8";
                      }
                      {
                        output = "spLFE:Out R";
                        input = "mixR:In 8";
                      }
                    ];

                    inputs = [
                      "spFL:In"
                      "spFR:In"
                      "spFC:In"
                      "spLFE:In"
                      "spRL:In"
                      "spRR:In"
                      "spSL:In"
                      "spSR:In"
                    ];

                    outputs = [
                      "mixL:Out"
                      "mixR:Out"
                    ];
                  };

                  "capture.props" = {
                    "node.name" = "effect_input.spatializer-virt-surround";
                    "media.class" = "Audio/Sink";
                    "audio.channels" = 8;
                    "audio.position" = [
                      "FL"
                      "FR"
                      "FC"
                      "LFE"
                      "RL"
                      "RR"
                      "SL"
                      "SR"
                    ];
                  };

                  "playback.props" = {
                    "node.name" = "effect_output.spatializer-virt-surround";
                    "node.passive" = true;
                    "audio.channels" = 2;
                    "audio.position" = [
                      "FL"
                      "FR"
                    ];
                  };
                };
              }
            ];
          };
        };
      };
    };
}
