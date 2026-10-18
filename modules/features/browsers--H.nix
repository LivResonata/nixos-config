{ inputs, ... }:

{
  flake.homeModules.browsers =
    {
      config,
      osConfig,
      pkgs,
      ...
    }:
    let
      sensitivesSecretsPath = toString inputs.sensitivesSecrets;
      sensitivesSecretsData = builtins.fromJSON (
        builtins.readFile "${sensitivesSecretsPath}/sensitives.json"
      );

      firefoxPolicies =
        let
          mkExtensionSettings = builtins.mapAttrs (
            _: pluginId: {
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/${pluginId}/latest.xpi";
              installation_mode = "force_installed";
            }
          );
        in
        {
          # Browser Policies
          WebsiteFilter.Block = sensitivesSecretsData.firefox.policies.websitefilter.block;

          EnableTrackingProtection = {
            Value = true;
            Locked = false;
            Cryptomining = true;
            Fingerprinting = true;
          };

          # Syntax: `"extension-id" = "extension-name"`
          ## The former can be found in the Add-on Links under More Information, simply click on "Copy add-on ID".
          ## The latter can be found in the url: `https://addons.mozilla.org/en-US/firefox/addon/<extension-name>/`
          ExtensionSettings = mkExtensionSettings {
            "uBlock0@raymondhill.net" = "ublock-origin";
            "{9a41dee2-b924-4161-a971-7fb35c053a4a}" = "enhanced-h264ify";
            "{446900e4-71c2-419f-a6a7-df9c091e268b}" = "bitwarden-password-manager";

            # Commented out or Disabled (Can still be installed imperatively)
            # "firefox@betterttv.net" = "betterttv";
            # "CanvasBlocker@kkapsner.de" = "canvasblocker";
            # "enhancerforyoutube@maximerf.addons.mozilla.org" = "enhancer-for-youtube";
          };

          # User Preferences
          ## WARN: Some values may not apply. Verify in `about:policies#errors`. If the page is missing, all is good.
          Preferences = {
            ## - Disable Quick Find
            "accessibility.typeaheadfind.manual" = {
              Value = false;
              Status = "locked";
            };
            ## - Ask whether to open or save new filetypes
            "browser.download.always_ask_before_handling_new_types" = {
              Value = true;
              Status = "locked";
            };
            ## - Restore search engine suggestions
            "browser.search.suggest.enabled" = {
              Value = true;
              Status = "locked";
            };
            ## - Disable URL bar auto fill by Firefox
            "browser.urlbar.autoFill" = {
              Value = false;
              Status = "locked";
            };
            ## -  Enable developer console text box or prompt box
            ## Also used alongside user stylesheets for theming.
            "devtools.chrome.enabled" = {
              Value = true;
              Status = "locked";
            };
            ## - Enable Vulkan Video Decoding
            ## May not utilize HW decoding at all despite Vulkan decoding being present.
            "media.hardware-video-decoding-vulkan.enabled" = {
              Value = false;
              Status = "user";
            };
            ## - Enforce DNS-over-HTTPS (DoH) | Unlocked Policy
            ## See: https://www.librewolf.net/docs/faq/#doh-what-is-the-currently-recommended-way-to-enable-doh
            ### - Allows the use of private IP addresses (RFC 1918) in DoH responses
            "network.trr.allow-rfc1918" = {
              Value = true;
              Status = "locked";
            };
            ### - Trusted Recursive Resolver (TRR) Mode
            #### 0 = Default Off; 2 = Custom; 3 = Warn if Unavailable; 5 = Off by Choice;
            #### See: https://wiki.mozilla.org/Trusted_Recursive_Resolver#DNS-over-HTTPS_Prefs_in_Firefox
            "network.trr.mode" = {
              # Value = if config.programs.zen-browser.policies.DNSOverHTTPS.Enabled then 3 else 5;
              Status = "user";
              Value = 5; # DoH seems to fail at unpredictable times. Fallback to OS DNS instead.
              Type = "number";
            };
            ### - Fallback DNS server (Only on Mode 1; Though, this mode as of 2026-07-24 does nothing and is reserved.)
            "network.trr.default_provider_uri" = {
              Value = "https://family.adguard-dns.com/dns-query";
              Status = "locked";
            };
            ### - Disables the canary telemetry detection request "use-application-dns.net" for DoH
            "network.trr.disable-heuristics" = {
              Value = true;
              Status = "locked";
            };
            ### - Retry on recoverable errors
            "network.trr.retry_on_recoverable_errors" = {
              Value = true;
              Status = "locked";
            };
            ### - Allow native fallback
            "network.trr.strict_native_fallback" = {
              Value = false;
              Status = "locked";
            };
            ## - Enable Enhanced Tracking Protection or Fingerprinting Protection
            "privacy.fingerprintingProtection" = {
              Value = true;
              Status = "locked";
            };
            ## - Enable Container Tabs
            "privacy.userContext.enabled" = {
              Value = true;
              Status = "locked";
            };
            ## - Enable userChrome browser customization
            "toolkit.legacyUserProfileCustomizations.stylesheets" = {
              Value = true;
              Status = "user";
            };
            ## - Use Native XDG Desktop Portal File Picker
            ### 1 = Always System
            "widget.use-xdg-desktop-portal.file-picker" = {
              Value = 1;
              Status = "locked";
              Type = "number";
            };
            ## - Disable alt menu
            "ui.key.menuAccessKeyFocuses" = {
              Value = false;
              Status = "locked";
            };
          };
        };
    in
    {
      imports = [
        inputs.zen-browser.homeModules.beta
      ];

      home.packages = with pkgs; [
        ungoogled-chromium
      ];

      programs = {
        # TODO: Add options for browser-of-choice or an exclusion list.
        firefox = {
          enable = true;
          configPath = "${config.xdg.configHome}/mozilla/firefox";

          policies = firefoxPolicies // {
            DNSOverHTTPS = {
              Enabled = true;
              ProviderURL = sensitivesSecretsData.networking.${osConfig.networking.hostName}.dns.firefox;
              Locked = false; # In case of DNS-over-HTTPS failures, an imperative switch is preferable.
            };

            Preferences = {
              ### - Custom DNS server (Used in Modes 2 and 3 and if selecting a custom source)
              "network.trr.custom_uri" = {
                Value = "${sensitivesSecretsData.networking.${osConfig.networking.hostName}.dns.firefox}";
                Status = "locked";
              };
              ### - Default DNS server
              "network.trr.uri" = {
                Value = "${sensitivesSecretsData.networking.${osConfig.networking.hostName}.dns.firefox}";
                Status = "locked";
              };
            };
          };
        };

        zen-browser = {
          enable = true;

          policies = firefoxPolicies // {
            DNSOverHTTPS = {
              Enabled = true;
              ProviderURL = sensitivesSecretsData.networking.${osConfig.networking.hostName}.dns.zen-browser;
              Locked = false; # In case of DNS-over-HTTPS failures, an imperative switch is preferable.
            };

            Preferences = {
              ### - Custom DNS server (Used in Modes 2 and 3 and if selecting a custom source)
              "network.trr.custom_uri" = {
                Value = "${sensitivesSecretsData.networking.${osConfig.networking.hostName}.dns.zen-browser}";
                Status = "locked";
              };
              ### - Default DNS server
              "network.trr.uri" = {
                Value = "${sensitivesSecretsData.networking.${osConfig.networking.hostName}.dns.zen-browser}";
                Status = "locked";
              };

              # Zen Browser Configuration
              ## - Enable DMABUF for screencasting on Niri or any apps using DMABUF.
              ### See: https://niri-wm.github.io/niri/Application-Issues.html#zen-browser
              "widget.dmabuf.force-enabled" = {
                Value = true;
                Status = "locked";
              };
            };
          };
        };
      };
    };
}
