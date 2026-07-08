{ ... }:

{
  flake.nixosModules.amdgpu =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.hardware.amdgpu;
    in
    {
      options.hardware.amdgpu = {
        enable = lib.mkEnableOption null // {
          default = true;
          example = false;
          description = "Enables AMDGPU custom defaults and PPFeatureMask safeties.";
        };
      };

      config = lib.mkIf cfg.enable {
        # There's a history here of which I'd rather let the code explain itself.
        assertions = lib.mkIf config.hardware.amdgpu.overdrive.enable [
          {
            # Ensures the safety boundaries are not tampered with.
            assertion =
              # Checks if the option matches either the default or the host-only setting.
              (
                config.hardware.amdgpu.overdrive.ppfeaturemask == "0xfff7bfff"
                || (
                  config.hardware.amdgpu.overdrive.ppfeaturemask == "0xfffd3fff"
                  && config.networking.hostName == "flos"
                )
              )
              # Both checks must be `true` which states the values are within set safety. Else, assert.
              &&
                # Checks if `boot.kernelParams` list of strings matches either the default or the host-only setting.
                ## Any other module can add another or its own PPFeatureMask outside of this module.
                ## Thus, better safe to check for any mention of it in the list.
                (
                  (lib.lists.any (
                    param: lib.strings.hasInfix "amdgpu.ppfeaturemask=0xfff7bfff" param
                  ) config.boot.kernelParams)
                  || (
                    (lib.lists.any (
                      param: lib.strings.hasInfix "amdgpu.ppfeaturemask=0xfffd3fff" param
                    ) config.boot.kernelParams)
                    && config.networking.hostName == "flos"
                  )
                );
            message = ''
              AMDGPU PPFeatureMask is set with a non-default value!

              Please reset configuration to either the default, 0xfff7bfff,
                or host-specific setup declared within `flake.nixosModules.amdgpu`.
              Any other value risks hardware damages. Overclocking and voltage tuning are not tolerated.

              Current PPFeatureMask: ${config.hardware.amdgpu.overdrive.ppfeaturemask}
              Expected PPFeatureMask for host, '${config.networking.hostName}': ${
                (if config.networking.hostName == "flos" then "0xfffd3fff" else "00xfff7bfff")
              }
            '';
          }
        ];

        boot = {
          kernelParams = [
            # Explicitly enable AMD DPM and PowerPlay
            ## See: https://wiki.gentoo.org/wiki/AMDGPU#Power_management
            "amdgpu.dpm=1"
          ];

          kernelModules = [ "zenpower" ];
          blacklistedKernelModules = [ "k10temp" ];
          extraModulePackages = with config.boot.kernelPackages; [ zenpower ];
        };

        environment = {
          systemPackages = with pkgs; [
            # TUI System Monitoring
            btop-rocm
            amdgpu_top
            nvtopPackages.amd
          ];

          sessionVariables = {
            # AMD RADV Vulkan
            ## See for shader cache: https://wiki.cachyos.org/configuration/gaming/#pre-caching-shaders-with-proton-cachyos--ge-and--em
            ##                       https://wiki.cachyos.org/configuration/gaming/#increase-maximum-shader-cache-size
            RADV_EXPERIMENTAL = "video_decode,video_encode"; # For video acceleration
            AMD_VULKAN_ICD = "RADV";
            MESA_SHADER_CACHE_MAX_SIZE = "12G";
          };
        };

        hardware = {
          graphics.enable32Bit = true;

          amdgpu = {
            zluda.enable = true;
            opencl.enable = true;

            overdrive = {
              # Double-ifs is redundant, but this is for the sake of being too careful.
              # <!> Do. Not. Create. Traumatic memory of hardware damage from overclock and voltage tuning.
              enable = if config.networking.hostName == "flos" then lib.mkForce true else lib.mkForce false;
              # Options below amends to `boot.kernelParams`.
              ppfeaturemask =
                if config.networking.hostName == "flos" then lib.mkForce "0xfffd3fff" else lib.mkForce "0xfff7bfff";
            };
          };
        };
      };
    };
}
