{ inputs, ... }:

{
  flake.homeModules.browsers =
    { osConfig, pkgs, ... }:
    let
      sensitivesSecretsPath = toString inputs.sensitivesSecrets;
      sensitivesSecretsData = builtins.fromJSON (
        builtins.readFile "${sensitivesSecretsPath}/sensitives.json"
      );
    in
    {
      imports = [
        inputs.zen-browser.homeModules.beta
      ];

      home.packages = with pkgs; [
        (vivaldi.override (
          { ... }:
          {
            # Additional parameters
            ## - https://github.com/NixOS/nixpkgs/pull/292147#issuecomment-2343586641
            enableWidevine = true;
            proprietaryCodecs = true;
          }
        ))
        ungoogled-chromium
        vivaldi-ffmpeg-codecs
      ];

      programs = {
        zen-browser = {
          enable = true;

          policies =
            let
              mkExtensionSettings = builtins.mapAttrs (
                _: pluginId: {
                  install_url = "https://addons.mozilla.org/firefox/downloads/latest/${pluginId}/latest.xpi";
                  installation_mode = "force_installed";
                }
              );
            in
            {
              DNSOverHTTPS = {
                Enabled = true;
                ProviderURL = sensitivesSecretsData.networking.${osConfig.networking.hostName}.dns.zen-browser;
                Locked = false;
              };

              # Syntax: `"extension-id" = "extension-name"`
              ## The latter can be found in the url: `https://addons.mozilla.org/en-US/firefox/addon/<extension-name>/`
              ExtensionSettings = mkExtensionSettings {
                #"firefox@betterttv.net" = "betterttv";
                "uBlock0@raymondhill.net" = "ublock-origin";
                "{446900e4-71c2-419f-a6a7-df9c091e268b}" = "bitwarden-password-manager";
                "{9a41dee2-b924-4161-a971-7fb35c053a4a}" = "enhanced-h264ify";
                #"{14a15c41-13f4-498e-986c-7f00435c4d00}" = "hyperchat";
                #"{762f9885-5a13-4abd-9c77-433dcd38b8fd}" = "return-youtube-dislikes";
              };
            };
        };
      };
    };
}
