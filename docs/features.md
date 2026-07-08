# Features

These are modular components that can be added to any hosts or users.

> [!Warning]
> If you're looking for proper Dendritic Pattern examples, this setup may be limited or does not follow the pattern at all.
> 
> However, a modular design is retained with Flake Parts and Import-tree as per its primary goal.
>
> Refer to [Inspiration and Limitations](<../README.md#Inspiration-and-Limitations>) for more information.

## Table of Contents

- [Adding Modules](<./features.md#Adding-Modules>)
  - [1. flake.nix](<./features.md#1-flakenix>)
  - [2. NixOS Host Configuration](<./features.md#2-NixOS-Host-Configuration>)
  - [3. Users via Home Manager](<./features.md#3-Users-via-Home-Manager>)
- [Editing Options](<./features.md#Editing-Options>)
- [List of Feature Modules](<./features.md#List-of-Feature-Modules>) 

## Adding Modules

**Flake Parts** and **Import-tree** make use of top-level modular configuration. In other words, no need to use `import` with relative paths. Simply list out names that are already imported into any per-host and per-user configuration.

The point is— unlike the usual host-centric or host-first configuration, the pattern follows **feature-first setup**. Likewise, also avoids duplicate code.

### 1. flake.nix

Any modules inside `./modules` will be imported automatically.

```
{
  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake {
      inherit inputs;
    } (inputs.import-tree ./modules);

  inputs = {
    # Flake Parts and Import-tree
    import-tree.url = "github:vic/import-tree";
    flake-parts.url = "github:hercules-ci/flake-parts";

    # (i) and other inputs...
  };
}
```

### 2. NixOS Host Configuration

Utilizes `flake.nixosConfiguratoins.<hostname>`. Includes `withSystem` for access to `packages` as noted in [Overlays in Packages](<../README.md#Overlays-and-Packages>).

Of course, substitute `<hostname>` with your PC's hostname and `<username>` with your username.

```
{
  self,
  inputs,
  withSystem,
  ...
}:

{
  flake.nixosConfigurations.<hostname> =
    withSystem "x86_64-linux" (
      { config, inputs', ... }:
      inputs.nixpkgs.lib.nixosSystem {
        specialArgs = {
          packages = config.packages;
          inherit inputs inputs';
        };

        modules = with self.nixosModules; [
          # (i) Add modular features here.
          moduleFeatureName

          # (i) Set available users using `flake.nixosModules.<username>` here.
          <username>

          # (i) Using modules from the List of Feature Modules as an example.
          audio
          plasma
          commonPackages
          commonPrograms
          commonServices
          # ... and more.
        ];
      };
    )
}
```

### 3. Users via Home Manager

Instead of using `flake.homeConfigurations.<username>`, `flake.homeModules.<username>` is used instead. The user module is loaded in a [NixOS Host Configuration](<./features.md#2-nixos-host-configuration>) of the same username first.

> [!Note]
> I've yet to understand how to properly use the `flake.homeConfigurations.\<username\> configuration.

Of course, substitute `<username>` with your username.

```
{
  self,
  inputs,
  ...
}:

{
  flake.homeModules.<username> =
    { ... }:
    {
      # Modular Configuration
      imports = with self.homeModules; [
        # (i) Using modules from the List of Features Modules as an example.
        commonPackages
        commonPrograms
        commonServices
      ];

      # Non-modular Configuration
      ## (i) Add other Home Manager options here.
      
      ## (i) Standard options example
      home = {
        username = "<username>";
        homeDirectory = "/home/<username>";
      };
    }
  
  flake.nixosModules.<username> =
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
        users.<username> = {
          # (i) User setup here. Consult `users.users.<name>` in NixOS Options Documentation.
        };
      };

      home-manager = {
        # TODO: Remove useGlobalPkgs and useUserPackages when `true` by default.
        useGlobalPkgs = true;
        useUserPackages = true;
        # (i) Import the associated `homeModules` for your user here. 
        users.<username> = self.homeModules.<username>;
      };
    };
  }
```

## Editing Options

Some modules provide options to customize a host or user's configuration outside the defaults through non-feature-centric means.

But for those that don't have options, the use of `lib.mkForce` or directly editing the feature modules are the two currently available methods that can override, overwrite, or add new options.

To know if a feature module have options and what it has, it is required to inspect each file manually as there is no documentation for it at the moment. However, the [List of Feature Modules](<./features.md#List-of-Feature-Modules>) can offer as a guide on which files to check via its **Has Options** column.

## List of Feature Modules

Module filenames are appended with either `H` and `N` for denoting Home Manager and NixOS module presence respectively. Likewise, the files and modules should be the same in-name.

Written in order of alphabetical sorting with folders first in `../modules/`.

Filename syntax: `moduleFeatureName--HN.nix`

| Module Name             | Folder | NixOS | Home Manager | Has Options | Description |
| ----------------------- | ------ | ----- | ------------ | ----------- | ----------- |
| audio                   | ./audio                         | &check; |         |         | Pipewire, Quantum, and VirtSurround. | 
| quantum                 | ./audio                         | &check; |         |         | Pipewire quantum parameters. |
| spatializerVirtSurround | ./audio/spatializerVirtSurround | &check; |         | &check; | Pipewire virtual surround via SADIE KU-100 spatializer. |
| niri                    | ./desktopEnvironment            | &check; |         |         | Niri with Noctalia Shell. |
| plasma                  | ./desktopEnvironment            | &check; |         |         | KDE Plasma with Plasma Login Manager. |
| amdgpu                  | ./hardware                      | &check; |         | &check; | AMDGPU graphic defaults and PPFeatureMask safeties. |
| theming                 | ./theming                       |         | &check; |         | Cursor, font options, icon packs, and Stylix options. |
| themingPresets          | ./theming                       |         | &check; | &check; | Contains custom preset themes for Stylix. |
| antivirus               |   | &check; |         |         | ClamAV daemon without auto-scanning. |
| browsers                |   |         | &check; |         | Contains web browsers. |
| commonPrograms          |   | &check; | &check; |         | Non-categorized program set. |
| commonPackages          |   | &check; | &check; |         | Non-categorized package set. |
| commonServices          |   | &check; | &check; |         | Non-categorized service set. |
| drawingTablet           |   | &check; |         | &check; | OpenTabletDriver and VEIKK driver. |
| editor                  |   | &check; | &check; |         | Contains text editors with more configurations for Home Manager. |
| flatpak                 |   | &check; | &check; | &check; | Enables Flatpak and has its own package categories to be set per-user. |
| fonts                   |   | &check; |         |         | Contains font packages and options outside theming modules. |
| gaming                  |   | &check; | &check; |         | Per-user and system-level game packages alongside Proton configurations. |
| git                     |   | &check; | &check; |         | Enables Git. (*That's it.*) |
| graphics                |   |         | &check; |         | Contains packages for graphic design and art. |
| inputMethod             |   |         | &check; |         | i18n and Fcitx5 with Mozc for Japanese IME. |
| performance             |   | &check; |         | &check; | Contains various performance tweaks, tuning, and services. |
| samba                   |   | &check; |         |         | Contains Samba Share settings and user `guest`. |
| shell                   |   | &check; | &check; |         | Utilizes ZSH, Starship, and holds shell aliases. |
| ssh                     |   | &check; | &check; |         | Contains SSH configurations. |
| virtualisation          |   | &check; |         |         | Contains Docker, Virt-Manager, and Waydroid setups. |
