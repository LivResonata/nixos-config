# NixOS Modular Configuration

My personal maze of trying to make sense of how I want my personal computers to work.

This is an overhaul of my private configuration from using NixOS the first time around the 05th of July 2025. Migration was done from a standard NixOS flake to a more modular setup with the help of [Flake Parts](https://flake.parts/) and [Import-tree](https://github.com/denful/import-tree).

## Table of Contents

- [Inspiration and Limitations](<README.md#Inspiration-and-Limitations>)
- [Hosts](<README.md#Hosts>)
- [Features](<README.md#Features>)
- [Overlays and Packages](<README.md#Overlays-and-Packages>)
- [Secrets and Sensitives](<README.md#Secrets-and-Sensitives>)
  - [Terminology](<README.md#Terminology>)
  - [Affected Files and Code](<README.md#Affected-Files-and-Code>)
- [Goals](<README.md#Goals>)
- [Credits](<README.md#Credits>)

## Inspiration and Limitations

This project is inspired by [The Dendritic Pattern](https://github.com/mightyiam/dendritic) by **mightyjam** and **[Vimjoyer](https://www.youtube.com/@vimjoyer)**'s coverage of it.

> [!Warning]
>As noted in the pattern guide, this repository and its configuration may be or is affected by the [anti-patterns](https://github.com/mightyiam/dendritic#anti-patterns) of "*Not declaring options*", "*specialArgs pass-thru*". and "*Lower-level module name proliferation*".

> [!Note]
> While noting that the guide mentions that [exceptions can be made](https://github.com/mightyiam/dendritic#fanaticism), the current setup mainly aims to make use of not needing relative import paths as its primary goal— resulting to being modular.
>
> Following the pattern faithfully may be done another time as a room for improvement.

## Hosts

"*I sometimes wonder how much difficulty other people have when naming their PCs and storage drives.*"

| Hostname | CPU | GPU | RAM |
| -------- | --- | --- | --- |
| flos     | AMD Athlon 3000G | AMD Radeon Vega 3 (iGPU) | 16GB (2x8GB) |

## Features

These are modular components that can be added to any hosts or users.

List of each features and its description is provided in the documentation link below:

> [Features at `./docs/features.md`](./docs/features.md)

It also contains on how to use the modules for both NixOS and Home Manager.

## Overlays and Packages

Located in [./modules/flakeParts.nix](./modules/flakeParts.nix) and [./modules/perSystemPackages.nix](./modules/perSystemPackages.nix), it makes uses of consumed overlays and independent package recipes located in [./overlays](./overlays) and [./pkgs](./pkgs).

The following code is used in NixOS Host Configurations to utilize `perSystem.packages`:

```
  flake.nixosConfigurations.<hostname> =
    withSystem "x86_64-linux" (
      { config, inputs', ... }:
      inputs.nixpkgs.lib.nixosSystem {
        specialArgs = {
          packages = config.packages;
          inherit inputs inputs';
        };
        
        modules = with self.nixosModules; [
          # Host, user, and feature modules here. 
        ];
      }
    );
```

> [!Note]
> I am still confused on whether there is a better way of overriding or creating packages that can see one another in overlays (e.g. `packages.kcgroup` being invisible to other `perSystem.packages`, resulting to build failure).
> 
> There may be room for improvement which I don't know nor understand yet, but for now— this will do.

## Secrets and Sensitives

> [!Warning]
> This repository makes use of [sops-nix](https://github.com/mic92/sops-nix) and [pkgs.sops](https://search.nixos.org/packages?channel=unstable&query=sops#show=sops) for encrypted values alongside items that are locally world-readable on NixOS builds.
>
> When taking any code, affected configurations must be modified to function outside this repository and its intended hosts and users.

### Terminology

- **Sensitives** — These shouldn't be public in a repository, but can be world-readable in local NixOS builds.

- **Secrets** — Must be encrypted at all times and isn't world-readable.

### Affected Files and Code

> [!Important]
> The associated `flake.nix` input, `sensitivesSecrets`, have to be removed.
>
> Likewise, any options that utilize the input and program also have to be modified to work without it or made to your own use-case. 

| File | Type |
| ---- | ---- |
| /flake.nix | Flake |
| ./modules/features/browsers\--H.nix | Features |
| ./modules/features/flatpak\--HN.nix | Features |
| ./modules/hosts/flos/configuration\--N.nix | NixOS Host Configuration |
| ./modules/hosts/flos/networking\--N.nix | NixOS Host Modules |
| ./modules/users/livresonata\--HN.nix | User Setup Modules |

And here's a reference regarding what code to modify or remove:

```
{ config, ... }:
let
  sensitivesSecretsPath = builtins.toString inputs.sensitivesSecrets;
  sensitivesSecretsData = builtins.fromJSON (builtins.readFile "${sensitivesSecretsPath}/sensitives.json");
in
{
  # For sensitives
  sensitivesExample = sensitivesSecretsData.<name>.<sub-trees>;
  
  # For secrets
  secretsExample = config.sops.secrets.<name>.path;
}
```

## Goals

These are ideas that may propel, are rooms of improvement, or are simply noted for the development of this configuration and repository.

1. - [ ] Utilize [The Dendritic Pattern](https://github.com/mightyiam/dendritic#the-dendritic-pattern) design faithfully.
2. - [ ] Implement [Impermanence](https://github.com/nix-community/impermanence).

## Credits

These guides, people, and repositories helped and are still helping me understand Nix, Nixpkgs, and NixOS.

- **[Vimjoyer](https://www.youtube.com/@vimjoyer)** on YouTube and their [own site](https://www.vimjoyer.com/) — Introduced me to NixOS around June 2025, and the Dendritic Pattern which inspired this configuration's development as its main guide.
- [The Dendritic Pattern](https://github.com/mightyiam/dendritic) by **mightyjam** on GitHub — The main documentation and author of the pattern.
- [Dendritic Patterns for Dendritic Aspects](https://github.com/Doc-Steve/dendritic-design-with-flake-parts/wiki/Dendritic_Aspects) by **Doc-Steve** on GitHub — Helped me visualize and modularize my setup. Though, my syntax currently differs from the guide.
- [dendritic-nixos](https://github.com/MATOO-Dev/dendritic-nixos) by **MATOO-Dev** on GitHub — Gave me my "*Eureka!*" moment which clicked many floating puzzle pieces in my mind on how to make the configuration work.
- **[Emergent Mind](https://www.youtube.com/@Emergent_Mind)** on YouTube — For the tutorial and practices about [secrets management with sops-nix](https://youtu.be/6EMNHDOY-wo), a three-part video.

And those behind-the-scenes that inspire and continue to keep me trying new stuff and understand it.

There could be more such as the NixOS Documentation, package and option searches, but I've got approximately 81 browser tabs involving this project to comb through. I suppose not attempting to overwhelm the list is a good idea.
