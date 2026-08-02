# Secrets and Sensitives

> [!Warning]
> This repository makes use of [sops-nix](https://github.com/mic92/sops-nix) and [pkgs.sops](https://search.nixos.org/packages?channel=unstable&query=sops#show=sops) for encrypted values alongside items that are locally world-readable on NixOS builds.
>
> When taking any code, affected configurations must be modified to function outside this repository and its intended hosts and users.

## Table of Contents

- [Table of Contents](<./secretsSensitives.md#Table-of-Contents>)
  - [Terminology](<secretsSensitives.md#Terminology>)
  - [Affected Files and Code](<secretsSensitives.md#Affected-Files-and-Code>)

## Terminology

- **Sensitives** — These shouldn't be public in a repository, but can be world-readable in local NixOS builds.

- **Secrets** — Must be encrypted at all times and isn't world-readable.

## Affected Files and Code

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
