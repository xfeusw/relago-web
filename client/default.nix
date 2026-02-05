{pkgs, ...}: let
  manifest = pkgs.lib.importJSON ./package.json;

  source = ./.;

  pnpmDeps = pkgs.fetchPnpmDeps {
    pname = manifest.name;
    version = manifest.version;
    src = source;
    fetcherVersion = 2;
    hash = "sha256-XTnuQqdriHhYqhe+dVkz4vYBjdVE4D4v3Zb2rXTE0vI=";
  };
in
  pkgs.stdenv.mkDerivation {
    pname = manifest.name;
    version = manifest.version;

    src = source;

    nativeBuildInputs = with pkgs; [
      nodejs_20
      pnpm_10
      pnpmConfigHook
      typescript
    ];

    inherit pnpmDeps;

    buildInputs = with pkgs; [
      vips
    ];

    buildPhase = ''
      runHook preBuild
      pnpm build
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      cp -R dist/* $out/

      runHook postInstall
    '';

    meta = with pkgs.lib; {
      # homepage = "https://relago.uz";
      # mainProgram = "${manifest.name}-start";
      # description = "Website of Xinux";
      license = with licenses; [cc-by-40];
      platforms = with platforms; linux ++ darwin;
      maintainers = with maintainers; [xfeusw];
    };
  }
