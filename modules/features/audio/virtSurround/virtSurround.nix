{ ... }:

{
  flake.nixosModules.virtSurround =
    { config, lib, ... }:
    let
      cfg = config.services.pipewire.virtSurround;

      cfgSofaSource = "/etc/nixos/modules/features/audio/virtSurround/D1_48K_24bit_256tap_FIR_SOFA.sofa";
      cfgSofaSymlink = "/etc/pipewire-hrtf/Spatializer/D1_48K_24bit_256tap_FIR_SOFA.sofa";
      cfgSofaGain = 1; # This depends on the .sofa file in use. Better left alone unless you know what to do, 'cuz I don't.
      cfgMixLRGain = 0.3; # Controls all mixers. Value `0.1` - `1.0`. Less for quiet, more for louder sound. Easier to tweak.
    in
    {
      options.services.pipewire.virtSurround = {
        enable = lib.mkEnableOption null // {
          default = false;
          example = true;
          description = ''
            Whether to enable 7.1 virtual surround via SADIE KU-100 spatializer.
            Ensure that audio programs are outputting to this virtSurround sink before any other sinks (e.g. EasyEffects).

            File: D1_48K_24bit_256tap_FIR_SOFA.sofa
            Copyright 2018, University of York. Licensed under the Apache License, Version 2.0 (the "License").
            More information in the `virtSurround.nix` file and "virtSurround" feature module folder.
          '';
        };
      };

      config = lib.mkIf cfg.enable {
        environment.etc."pipewire-hrtf/Spatializer/D1_48K_24bit_256tap_FIR_SOFA.sofa" = {
          # Sofa File - SADIE D01 - Neumann KU 100 - Far-field HRTF
          ## License: Apache License 2.0
          /*
            Copyright 2018, University of York. Licensed under the Apache License, Version 2.0 (the "License");
            You may not use this database except in compliance with the License. You may obtain a copy of the License here.
            Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS,
            WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions
            and limitations under the License. All measurements are Copyright University of York. The University of York makes no representation or
            warranties with respect to the contents hereof and specifically disclaim any implied warranties or merchantability or
            fitness for any particular purpose. The University of York also reserves the right to modify the database and
            its documentation without the obligation of notifying any person of the changes.' The original dataset must be
            referenced whenever used in original or modified form. If used for academic work, please cite the following Open Access journal paper DOI: 10.3390/app8112029
          */
          ## See: https://www.york.ac.uk/sadie-project/database.html
          ##      https://airtable.com/appayGNkn3nSuXkaz/shruimhjdSakUPg2m/tbloLjoZKWJDnLtTc

          source = cfgSofaSource;
          mode = "symlink";
        };

        services.pipewire.extraConfig.pipewire = {
          "20-virtSurround" = {
            # Spatializer Sink
            ## See: https://gitlab.freedesktop.org/pipewire/pipewire/-/blob/master/src/daemon/filter-chain/spatializer-single.conf
            ##      https://gitlab.freedesktop.org/pipewire/pipewire/-/wikis/Filter-Chain

            "context.modules" = [
              {
                name = "libpipewire-module-filter-chain";
                flags = [ "nofail" ];

                args = {
                  "node.description" = "Spatial Virt-Surround 7.1 Sink";
                  "media.name" = "Spatial Virt-Surround 7.1 Sink";

                  "filter.graph" = {
                    nodes = [
                      {
                        type = "sofa";
                        label = "spatializer";
                        name = "spFL";
                        config = {
                          filename = cfgSofaSymlink;
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
                          filename = cfgSofaSymlink;
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
                          filename = cfgSofaSymlink;
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
                          filename = cfgSofaSymlink;
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
                          filename = cfgSofaSymlink;
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
                          filename = cfgSofaSymlink;
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
                          filename = cfgSofaSymlink;
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
                          filename = cfgSofaSymlink;
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
                    "node.name" = "effect_input.virtSurround";
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
                    "node.name" = "effect_output.virtSurround";
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
