{ pkgs, lib }:
let
  inherit (pkgs) htmlNix;
  src = ./site;
in
htmlNix.mkServeFromSite (htmlNix.mkSiteFrom {
  inherit src;
  templater = context: pkgs.lib.pipe context [
    # Add basic template
    lib.templaters.basic

    # Add about page
    ({ site, mkPage, ... }@result: {
      site = site // {
        "about.html" = with lib.tags; mkPage [
          (h1 "About")
          (p "testy test test")
        ];
      };
    })
  ];
})
