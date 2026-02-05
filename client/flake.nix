{
  description = "React-based client application for Relago";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    treefmt-nix.url = "github:numtide/treefmt-nix";

    pnpm2nix = {
      url = "github:FliegendeWurst/pnpm2nix-nzbr";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-parts,
    treefmt-nix,
    pnpm2nix,
    ...
  } @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} ({...}: {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      perSystem = {pkgs, system, ...}: let
        treefmtEval = treefmt-nix.lib.evalModule pkgs (import ./nix/treefmt.nix);

        nodejs = pkgs.nodejs_20;
        pnpm = pkgs.pnpm_10;
        in {
          formatter = treefmtEval.config.build.wrapper;

          devShells.default = import ./nix/shell.nix {inherit pkgs nodejs pnpm;};

          packages.default = pkgs.callPackage ./nix/package.nix {inherit pnpm2nix system;};

          checks.formatting = treefmtEval.config.build.check self;
        };
    });
}
