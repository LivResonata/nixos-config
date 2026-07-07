{
  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake {
      inherit inputs;
    } (inputs.import-tree ./modules);

  inputs = {
    # Flake Parts and Import-tree
    ## Can lead towards the Dendritic Pattern.
    import-tree.url = "github:vic/import-tree";
    flake-parts.url = "github:hercules-ci/flake-parts";

    # Sensitives and Secrets
    ## Must be removed alongside relevant code if this configuration
    ## is set up elsewhere.
    sensitivesSecrets = {
      url = "git+ssh://git@github.com/LivResonata/nixos-secrets.git?ref=main&shallow=1";
      flake = false;
    };

    # Package Repositories
    ## NixOS Official Repos
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    ## Nix User Repository - https://github.com/nix-community/NUR
    # nur = {
    #   url = "github:nix-community/NUR";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    # Single Package Channels
    ## Affinity-Nix - by mrshmllow
    # affinity-nix.url = "github:mrshmllow/affinity-nix";

    ## Home Manager - For per-user configuration
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ## Nixcord - Declarative Vencord plugins and options
    nixcord.url = "github:flameflag/nixcord";

    ## Nix-CachyOS-Kernel - https://github.com/xddxdd/nix-cachyos-kernel
    ### Switch to `master` branch by removing `release` for bleeding-edge.
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";

    ## Nix-Flatpak - Declarative flatpak manager for NixOS
    nix-flatpak.url = "github:gmodena/nix-flatpak";

    ## Noctalia Shell - A sleek and minimal desktop shell thoughtfully crafted for Wayland
    noctalia = {
      url = "github:noctalia-dev/noctalia";

      # Uncomment if Noctalia's Cachix binary cache isn't in use.
      ## See: https://docs.noctalia.dev/v5/getting-started/nixos/?section=binary-cache#binary-cache
      #inputs.nixpkgs.follows = "nixpkgs";
    };

    ## Noctalia Greeter
    ## - A minimal login greeter for greetd that matches the look and feel of Noctalia Shell
    noctalia-greeter = {
      url = "github:noctalia-dev/noctalia-greeter";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ## Declarative KDE Plasma Management
    # plasma-manager = {
    #   url = "github:nix-community/plasma-manager";
    #   inputs.nixpkgs.follows = "nixpkgs";
    #   inputs.home-manager.follows = "home-manager";
    # };

    ## Preload-NG - Adaptive readahead daemon
    preload-ng.url = "github:miguel-b-p/preload-ng";

    ## QtEngine - A Qt6/Qt5 platform theme using the KDE Color Scheme format
    qtengine = {
      url = "github:kossLAN/qtengine";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ## sops-nix - Atomic, declarative, reproducible secrets
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ## Stylix - NixOS Theming Framework
    stylix = {
      url = "github:nix-community/stylix/";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ## Zen Browser for Nix - by 0xc000022070
    zen-browser = {
      # Remove the `/beta` directory to allow Twilight branch to sync
      url = "github:0xc000022070/zen-browser-flake/beta";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
