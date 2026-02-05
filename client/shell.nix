{pkgs}:
pkgs.mkShell {
  buildInputs = with pkgs; [
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
