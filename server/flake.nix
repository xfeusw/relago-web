{
  description = "Server for Relago";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = {
    self,
    nixpkgs,
    flake-parts,
    ...
  } @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} ({...}: {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      # flake.nixosModules = {
      #   server = import ./module.nix self;
      # };

      perSystem = {
        pkgs,
        system,
        ...
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
      in {
        formatter = pkgs.nixfmt-tree;
        # devShells.default = import ./shell.nix {inherit pkgs hpkgs;};

        packages.default = hlib.overrideCabal (hpkgs.callCabal2nix "relago" ./. {}) (old: {
          doCheck = true;
          doHaddock = false;
          enableLibraryProfiling = false;
          enableExecutableProfiling = false;
        });
      };
    });
}
