final: prev: {
  # Code taken from github:jovian-experiments/jovian-nixos
  kcgroups = final.callPackage ./kcgroups.nix { };
  dmemcg-booster = final.callPackage ./dmemcg-booster.nix { };
  plasma-foreground-booster = final.callPackage ./plasma-foreground-booster.nix { };

  # Added packages maintained by 'livresonata'.
  niri-focused-booster = final.callPackage ./niri-focused-booster.nix { };
}
