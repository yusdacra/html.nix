{ pkgs, lib }:
let
  inherit (pkgs) htmlNix;
  src = ./site;
in
htmlNix.mkServeFromSite (htmlNix.mkSiteFrom {
  inherit src;
  templater = lib.templaters.basic;
})
