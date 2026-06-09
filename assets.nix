{
  fetchPnpmDeps,
  nodejs,
  pnpm,
  pnpmConfigHook,
  stdenv,
  src,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "demo_web";
  version = "0-unstable";
  inherit src;

  nativeBuildInputs = [
    nodejs # in case scripts are run outside of a pnpm call
    pnpmConfigHook
    pnpm # At least required by pnpmConfigHook, if not other (custom) phases
  ];

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    fetcherVersion = 3;
    hash = "sha256-CWWN440rX9Ci7fu4HFjWhmsjSkg5U4FIjf4ZibXJsN4=";
  };

  buildPhase = ''
    pnpm build
  '';

  installPhase = ''
    mkdir -p $out/share
    cp -ar priv $out/share
  '';
})
