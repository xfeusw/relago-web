{
  pkgs ? let
    lock = (builtins.fromJSON (builtins.readFile ./flake.lock)).nodes.nixpkgs.locked;
    nixpkgs = fetchTarball {
      url = "https://github.com/nixos/nixpkgs/archive/${lock.rev}.tar.gz";
      sha256 = lock.narHash;
    };
  in
    import nixpkgs {overlays = [];},
}: let
  hlib = pkgs.haskell.lib;
  hpkgs = pkgs.haskell.packages."ghc910".override {
    overrides = self: super: {
      tasty-wai = hlib.dontCheck (hlib.doJailBreak super.tasty-wai);
      servant-client = hlib.dontCheck (hlib.doJailbreak super.servant-client);
      esqueleto = hlib.dontCheck (hlib.doJailbreak super.esqueleto);
      optparse-generic = hlib.dontCheck (hlib.doJailbreak super.optparse-generic);
      postgresql-simple = hlib.dontCheck (hlib.doJailbreak super.postgresql-simple);
      strict-containers = hlib.dontCheck (hlib.doJailbreak super.strict-containers);
    };
  };
in
  hlib.overrideCabal (hpkgs.callCabal2nix "relago" ./. {}) (old: {
    doCheck = true;
    doHaddock = false;
    enableLibraryProfiling = false;
    enableExecutableProfiling = false;
  })
  
# …/uzinfocom/relago-web/server main*​​ ⇡
# ❄️ impure relago-server-dev-env ❯ nix build .
# path '/home/xfeusw/workspace/uzinfocom/relago-web/server' does not contain a 'flake.nix', searching up
# error: flake 'git+file:///home/xfeusw/workspace/uzinfocom/relago-web' does not provide attribute 'packages.x86_64-linux.default' or 'defaultPackage.x86_64-linux'

