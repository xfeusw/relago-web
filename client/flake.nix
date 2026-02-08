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
        "aarch64-darwin"
      ];

      flake.nixosModules = {
        server = import ./module.nix self;
      };

      perSystem = {
        pkgs,
        system,
        ...
      }: {
        formatter = pkgs.nixfmt-tree;
        devShells.default = import ./shell.nix {inherit pkgs;};
        packages.default = pkgs.callPackage ./default.nix {inherit pkgs;};
      };
    });
}
