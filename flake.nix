{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flakeUtils.url = "github:numtide/flake-utils";
  };

  outputs = { self, flakeUtils, nixpkgs }:
    flakeUtils.lib.eachDefaultSystem (system:
      let
        utils = import ./utils.nix;

        lib = {
          tags = import ./tags.nix { inherit utils; };

          templaters = {
            basic = import ./templaters/basic.nix;
          };
        };

        pkgsLib = (final: prev: {
          htmlNix = import ./pkgs-lib.nix { pkgs = prev; utils = utils // { inherit (lib) tags; }; };
        });

        pkgs = import nixpkgs { inherit system; overlays = [ pkgsLib ]; };
      in
      {
        inherit lib;

        overlays = {
          inherit pkgsLib;
        };

        apps = with flakeUtils.lib; {
          site = mkApp {
            drv = let inherit (pkgs) htmlNix; in
              htmlNix.mkServeFromSite (htmlNix.mkSiteFrom { src = ./examples/site; templater = lib.templaters.basic; });
            name = "serve";
          };
          basicServe = mkApp {
            drv = import ./examples/serve.nix { inherit (lib) tags; inherit pkgs; };
            name = "serve";
          };
        };

        examples = {
          tags = import ./examples/tags.nix lib.tags;
        };
      });
}
