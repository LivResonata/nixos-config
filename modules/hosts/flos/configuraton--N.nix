{
  self,
  inputs,
  withSystem,
  ...
}:

{
  flake.nixosConfigurations.flos =
    # Utilizes withSystem and specialArgs to make use of perSystem packages within this host.
    # This is done despite the Dendritic Pattern advising against specialArgs since brain cannot brain anymore.
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
          performance
          samba
          shell
          ssh
          virtualisation
        ];
      }
    );

  flake.nixosModules.flosConfiguration =
    { ... }:
    let
      sensitivesSecretsPath = toString inputs.sensitivesSecrets;
    in
    {
      imports = [
        inputs.sops-nix.nixosModules.sops
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

        # Binary Caches
        ## Noctalia Shell
        ### See: https://docs.noctalia.dev/v5/getting-started/nixos/?section=binary-cache#binary-cache
        ## Nix-CachyOS-Kernel (xuyh0120/Lantian)
        ### See: https://github.com/xddxdd/nix-cachyos-kernel#binary-cache
        extra-substituters = [
          "https://noctalia.cachix.org"
          "https://attic.xuyh0120.win/lantian"
        ];

        extra-trusted-public-keys = [
          "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
          "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
        ];
      };

      # Custom feature module options
      hardware.performance.dmemcg.enable = false;
      services.pipewire.virtSurround.enable = true;
      hardware.drawingTablet.platform = "opentabletdriver";

      # Standard options
      environment.sessionVariables = {
        # Setting Wayland automatically in apps
        NIXOS_OZONE_WL = 1; # For Chromium and Electron
      };

      # Unsure if this should be host-centric or modular in "./modules/features".
      sops = {
        defaultSopsFile = "${sensitivesSecretsPath}/secrets.yaml";
        validateSopsFiles = false;

        age = {
          generateKey = true;
          keyFile = "/var/lib/sops-nix/key.txt";
          sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
        };

        secrets = {
          # Outputs to /run/secrets-for-users
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
