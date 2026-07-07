{ ... }:

{
  flake.homeModules.inputMethod =
    { pkgs, ... }:
    {
      # i18n and Fcitx5
      i18n.inputMethod = {
        enable = true;
        type = "fcitx5";

        fcitx5 = {
          ignoreUserConfig = false;
          fcitx5-with-addons = pkgs.kdePackages.fcitx5-with-addons;
          addons = with pkgs; [
            fcitx5-mozc
            fcitx5-gtk
          ];

          # Refer to the Fcitx5 site to complete Wayland input setup.
          ## https://fcitx-im.org/wiki/Using_Fcitx_5_on_Wayland
          waylandFrontend = true;

          settings = {
            # ~/.config/fcitx5/profile
            inputMethod = {
              GroupOrder."0" = "Default";

              "Groups/0" = {
                Name = "Default";
                "Default Layout" = "us";
                DefaultIM = "mozc";
              };

              "Groups/0/Items/0".Name = "keyboard-us";
              "Groups/0/Items/1" = {
                Name = "mozc";
                Layout = "us";
              };
            };

            # ~/.config/fcitx5/config
            globalOptions = {
              Hotkey = {
                EnumerateWithTriggerKeys = "True";
                EnumerateSkipFirst = "False";
                ModifierOnlyKeyTimeout = "250";
              };

              "Hotkey/TriggerKeys" = {
                "0" = "Control+Shift+space";
                "1" = "Zenkaku_Hankaku";
                "2" = "Hangul";
              };

              "Hotkey/EnumerateGroupForwardKeys"."0" = "Super+space";
              "Hotkey/EnumerateGroupBackwardKeys"."0" = "Shift+Super+space";

              "Hotkey/ActivateKeys"."0" = "Hangul_Hanja";
              "Hotkey/DeactivateKeys"."0" = "Romaja";

              "Hotkey/PrevPage"."0" = "Up";
              "Hotkey/NextPage"."0" = "Down";

              "Hotkey/PrevCandidate"."0" = "Shift+tab";
              "Hotkey/NextCandidate"."0" = "Tab";

              "Hotkey/TogglePreedit"."0" = "Contro+Alt+p";

              Behavior = {
                ActiveByDefault = "False";
                resetStateWhenFocusIn = "No";
                ShareInputState = "No";
                PreeditEnabledByDefault = "True";
                ShowInputMethodInformation = "True";
                showInputMethodInformationWhenFocusIn = "False";
                CompactInputMethodInformation = "True";
                ShowFirstInputMethodInformation = "True";
                DefaultPageSize = "5";
                OverrideXkbOption = "False";
                PreloadInputMethod = "True";
                AllowInputMethodForPassword = "False";
                ShowPreeditForPassword = "False";
                AutoSavePeriod = "30";
              };
            };
          };
        };
      };
    };
}
