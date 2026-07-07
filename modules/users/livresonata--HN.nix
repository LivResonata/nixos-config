{
  self,
  inputs,
  ...
}:

{
  flake.homeModules.livresonata =
    {
      osConfig,
      lib,
      ...
    }:
    {
      # Modular Configuration
      imports = with self.homeModules; [
        # Features
        ## In order of ascending folder-file names.
        theming # folder: theming
        browsers
        commonPackages
        commonPrograms
        commonServices
        editor
        flatpak
        gaming
        git
        graphics
        inputMethod
        shell
        ssh
      ];

      # Non-modular Configuration
      ## Custom module options
      #theming.preset = "everforest-dark-medium";

      ## Standard options
      home = {
        username = "livresonata";
        homeDirectory = "/home/livresonata";
      };

      services.flatpak.extraCategories = [
        "audio"
        "gaming"
        "graphics"
        "noctalia"
        "sensitives"
      ];

      xdg = {
        enable = true;

        userDirs = {
          enable = true;
          createDirectories = true;
          setSessionVariables = false;

          # Move to external HDD for media files
          music = if osConfig.networking.hostName == "flos" then "/media/Iris/livresonata/Music" else null;
          pictures =
            if osConfig.networking.hostName == "flos" then "/media/Iris/livresonata/Pictures" else null;
        };
      };

      # HM 26.05 default. Legacy had `config.gtk.theme`.
      gtk.gtk4.theme = lib.mkDefault null;

      # Let Home Manager install and manage itself.
      programs.home-manager.enable = true;

      # This value determines the Home Manager release that your configuration is
      # compatible with. This helps avoid breakage when a new Home Manager release
      # introduces backwards incompatible changes.
      #
      # You should not change this value, even if you update Home Manager. If you do
      # want to update the value, then make sure to first check the Home Manager
      # release notes.
      home.stateVersion = "25.05"; # Please read the comment before changing.
    };

  flake.nixosModules.livresonata =
    {
      config,
      pkgs,
      ...
    }:
    {
      imports = [
        inputs.home-manager.nixosModules.default
      ];

      users = {
        mutableUsers = false;

        users.livresonata = {
          shell = if config.programs.zsh.enable then pkgs.zsh else pkgs.bash;
          isNormalUser = true;
          description = "Liv Resonata";
          hashedPasswordFile = config.sops.secrets.password-livresonata.path;
          group = "wheel";
          extraGroups = [
            "networkmanager"
            "i2c"
            "realtime"
            "public"
            "libvirtd"
            "kvm"
            "adbusers"
          ];
        };
      };

      home-manager = {
        # TODO: Remove useGlobalPkgs and useUserPackages when `true` by default.
        useGlobalPkgs = true;
        useUserPackages = true;
        users.livresonata = self.homeModules.livresonata;
      };

      time.timeZone = "Asia/Manila";
      i18n = {
        defaultLocale = "en_PH.UTF-8";

        extraLocaleSettings = {
          LC_ADDRESS = "fil_PH";
          LC_IDENTIFICATION = "fil_PH";
          LC_MEASUREMENT = "fil_PH";
          LC_MONETARY = "fil_PH";
          LC_NAME = "fil_PH";
          LC_NUMERIC = "fil_PH";
          LC_PAPER = "fil_PH";
          LC_TELEPHONE = "fil_PH";
          LC_TIME = "fil_PH";
        };
      };
    };
}
