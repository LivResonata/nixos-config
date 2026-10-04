{
  self,
  inputs,
  withSystem,
  ...
}:

{
  flake.nixosConfigurations.flos =
    # Utilizes withSystem and specialArgs to make use of perSystem packages within this host.
    ## See: https://flake.parts/module-arguments#withsystem
    ##      https://github.com/mightyiam/dendritic#specialargs-pass-thru
    withSystem "x86_64-linux" (
      { config, inputs', ... }:
      inputs.nixpkgs.lib.nixosSystem {
        specialArgs = {
          packages = config.packages;
          inherit inputs inputs';
        };

        modules = with self.nixosModules; [
          # Host Configuration
          flosNetworking
          flosHardwareAuto
          flosHardwareExtra
          flosConfiguration

          # Users
          livresonata

          # Features
          ## In order of ascending folder-file names.
          audio # folder: audio
          noctaliaWithKDE # folder: desktopEnvironment/add-ons
          # gnome # folder: desktopEnvironment
          mango # folder: desktopEnvironment
          niri # folder: desktopEnvironment
          # plasma # folder: desktopEnvironment
          amdgpu # folder: hardware
          antivirus
          commonPackages
          commonPrograms
          commonServices
          drawingTablet
          editor
          flatpak
          fonts
          gaming
          git
          networking
          performance
          samba
          shell
          ssh
          virtualisation
        ];
      }
    );

  flake.nixosModules.flosConfiguration =
    { lib, pkgs, ... }:
    let
      sensitivesSecretsPath = toString inputs.sensitivesSecrets;
    in
    {
      imports = [
        inputs.sops-nix.nixosModules.sops

        # Globally use Chaotic-Nyx
        inputs.chaotic.nixosModules.default
      ];

      nixpkgs.config.allowUnfree = true;
      nix.settings = {
        allowed-users = [
          "root"
          "@wheel"
        ];

        experimental-features = [
          "nix-command"
          "flakes"
          "cgroups"
        ];
      };

      # Custom NixOS feature module options
      ## Enable/Disable Options
      networking.protonvpn.enable = true;
      fonts.monochromeEmoji.enable = true;
      programs.mango.withUWSM.enable = true;
      hardware.performance.dmemcg.enable = false;
      services.pipewire.virtSurround.enable = true;
      virtualisation.features.waydroid.enable = false;
      ## Strings and Other Types
      programs.niri.package = lib.mkForce pkgs.niri_git; # Provided from Chaotic-Nyx.
      hardware.drawingTablet.platform = "opentabletdriver";

      # Standard options
      environment.sessionVariables = {
        # Setting Wayland automatically in apps
        NIXOS_OZONE_WL = 1; # For Chromium and Electron
      };

      # Unsure if this should be host-centric or modular in "./modules/features".
      sops = {
        defaultSopsFile = "${sensitivesSecretsPath}/secrets.yaml";

        # The option documentation in `sops-nix` says:
        # Check all sops files at evaluation time. This requires sops files to be added to the nix store.
        ## The guide by Emergent Mind has it set to `false`. The default is `true`.
        ### Unsure what's the practical difference yet other than possibly avoiding the nix store.
        validateSopsFiles = false;

        age = {
          generateKey = true;
          keyFile = "/var/lib/sops-nix/key.txt";
          sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
        };

        secrets = {
          # Outputs to /run/secrets-for-users
          ## Enabling this option causes the secret to be decrypted before users and groups are created.
          password-livresonata = {
            neededForUsers = true;
          };
        };
      };

      # This value determines the NixOS release from which the default
      # settings for stateful data, like file locations and database versions
      # on your system were taken. It‘s perfectly fine and recommended to leave
      # this value at the release version of the first install of this system.
      # Before changing this value read the documentation for this option
      # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
      system.stateVersion = "25.05"; # Did you read the comment?
    };
}
