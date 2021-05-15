{ tags, pkgsLib, pkgs ? import <nixpkgs> { overlays = [ pkgsLib ]; } }:
with pkgs.htmlNix;
let
  index = with tags;
    html [
      (body [
        (p "Hello world!")
        (link "./ex.html" "say bye")
      ])
    ];

  ex = with tags;
    html [
      (body [
        (p "Bye world!")
        (link "./index.html" "go back")
      ])
    ];
in
mkServePathScript (mkSitePath { "index.html" = index; "ex.html" = ex; })
