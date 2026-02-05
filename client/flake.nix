{
  description = "React-based client application for Relago";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
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
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      # flake = {

      # }

      perSystem = {
        pkgs,
        system,
        ...
      }: let
        treefmtEval = treefmt-nix.lib.evalModule pkgs (import ./nix/treefmt.nix);
      in {
        formatter = treefmtEval.config.build.wrapper;

        devShells.default = import ./shell.nix {inherit pkgs;};

        packages.default = pkgs.callPackage ./nix/package.nix {inherit pkgs;};
      };
    });
}
