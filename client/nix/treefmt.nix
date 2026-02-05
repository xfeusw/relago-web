{
  projectRootFile = "flake.nix";

  programs.nixfmt.enable = true;
  programs.prettier.enable = true;

  settings.formatter.prettier.excludes = [
    "pnpm-lock.yaml"
    "*.svg"
  ];
}
