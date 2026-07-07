{
  rustPlatform,
  fetchFromGitLab,
  pkg-config,
  dbus,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "dmemcg-booster";
  version = "0.1.2";

  src = fetchFromGitLab {
    domain = "gitlab.steamos.cloud";
    owner = "holo";
    repo = "dmemcg-booster";
    tag = finalAttrs.version;
    hash = "sha256-qETBTccMJmB5IJPBK1sLTUdtpPfLFMKFwewLqpB/PgM=";
  };

  postPatch = ''
    substituteInPlace *.service \
      --replace-fail /usr/bin/dmemcg-booster $out/bin/dmemcg-booster
  '';

  cargoHash = "sha256-dIWUQoHB2nFvHvaq3aDWItifFKHBsJ6EJjIbrM/prIw=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    dbus
  ];

  postInstall = ''
    #install -Dm644 dmemcg-booster-system.service "$out/lib/systemd/system/dmemcg-booster-system.service"
    install -Dm644 dmemcg-booster-user.service "$out/lib/systemd/user/dmemcg-booster-user.service"
  '';
})
