{pkgs}:
pkgs.mkShell {
  name = "relago-root-shell";

  packages = with pkgs; [
    nixd
    statix
    deadnix
    alejandra
  ];

  NIX_CONFIG = "extra-experimental-features = nix-command flakes";
}
