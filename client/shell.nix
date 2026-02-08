{
  pkgs ? let
    lock = (builtins.fromJSON (builtins.readFile ./flake.lock)).nodes.nixpkgs.locked;
    nixpkgs = fetchTarball {
      url = "https://github.com/nixos/nixpkgs/archive/${lock.rev}.tar.gz";
      sha256 = lock.narHash;
    };
  in
    import nixpkgs {overlays = [];},
}:
pkgs.mkShell {
  buildInputs = with pkgs; [
    nixd

    nodejs_20
    pnpm_10
    eslint

    nodePackages.typescript
    nodePackages.typescript-language-server

    treefmt
    nixfmt
    nodePackages.prettier
    nodePackages.eslint

    git
  ];

  shellHook = ''
    echo "React + TypeScript + Vite development environment"
    echo "Node version: $(node --version)"
    echo "pnpm version: $(pnpm --version)"
    echo ""
    echo "Formatting: treefmt"
    echo ""
  '';

  PNPM_HOME = "${toString ./.}/.pnpm-store";
}
