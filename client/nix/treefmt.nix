{
  projectRootFile = "flake.nix";

  programs.alejandra.enable = true;
  programs.prettier.enable = true;
  programs.eslint.enable = true;

  settings.formatter.prettier.excludes = [
    "pnpm-lock.yaml"
    "*.svg"
  ];
}
