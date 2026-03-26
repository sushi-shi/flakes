{ nixpkgs ? import <nixpkgs> {}}:
let
  inherit (nixpkgs) pkgs;

  flake = builtins.getFlake (toString ./.);
  flakePkgs = flake.packages.${builtins.currentSystem};
in
pkgs.mkShell {
  packages = with flakePkgs; [
    fig2ps
    steel-city-comic
  ] ++ (with pkgs; [
    fig2dev
    ghostscript
    gnuplot
    graphviz
    gv
    inkscape
    texlive.combined.scheme-full
    xfig
  ]);
}
