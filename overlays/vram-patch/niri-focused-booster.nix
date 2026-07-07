{
  lib,
  fetchFromGitHub,
  rustPlatform,
  git,
  cargo,
  glibc,
  libgcc,
  systemd,
  dmemcg-booster,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "niri-focused-booster";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "1Naim";
    repo = "niri-focused-booster";
    tag = finalAttrs.version;
    hash = "sha256-a+aiiKLxYCxqDwHhVnzByn/SA3Q7c/Ok/Z+31MESCkw=";
  };

  cargoHash = "sha256-b5TkOaI2/pSX2uugkViKy13tUpptOHAPY6jR+RdaNUo=";

  nativeBuildInputs = [
    git
    cargo
  ];

  builtInputs = [
    glibc
    libgcc
    systemd
    dmemcg-booster
  ];

  meta = {
    description = "Leverages dmemcg to prioritize GPU memory for the focused app in Niri.";
    homepage = "https://github.com/1Naim/niri-focused-booster";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [
      livresonata
    ];
  };
})
