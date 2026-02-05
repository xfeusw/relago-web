{pkgs, nodejs, pnpm}:
pkgs.mkShell {
  buildInputs = with pkgs; [
    nodejs
    pnpm
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
