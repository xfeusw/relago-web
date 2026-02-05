{
  pkgs,
  hpkgs,
  ...
}:
pkgs.stdenv.mkDerivation {
  name = "relago-server-dev";

  nativeBuildInputs = with pkgs; [
    git
    nixd
    statix
    deadnix
    alejandra
  ];

  # Runtime dependencies
  buildInputs = [
    hpkgs.cabal-install
    hpkgs.cabal-add
    hpkgs.haskell-language-server
    hpkgs.fourmolu
    hpkgs.hlint
    hpkgs.hpack
    hpkgs.cabal-fmt
    hpkgs.postgresql-libpq
    hpkgs.postgresql-libpq-configure

    pkgs.just
    pkgs.alejandra
    pkgs.zlib
    pkgs.treefmt
    pkgs.libpq.dev
    pkgs.zlib.dev
    pkgs.postgresql
    pkgs.libz
    pkgs.libpq.pg_config
    pkgs.pkg-config
    pkgs.xz
  ];

  shellHook = ''
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${pkgs.postgresql}/lib
  '';

  # Environmental variables
  NIX_CONFIG = "extra-experimental-features = nix-command flakes";
}
