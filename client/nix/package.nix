{ pnpm2nix, system }:
pnpm2nix.packages.${system}.mkPnpmPackage {
  src = ../.;
}
