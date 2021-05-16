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
          # Convert Nix expressions to HTML
          tags = import ./tags.nix { inherit utils; };
          # Convert Nix expressions to CSS
          css = import ./css.nix { inherit utils; };

          # Various site templaters
          templaters = {
            # Basic templater with purecss, mobile responsive layout and supports posts
            basic = import ./templaters/basic.nix;
          };
        };

        pkgsLib = (final: prev: {
          htmlNix = import ./pkgs-lib.nix { pkgs = prev; utils = utils // { inherit (lib) tags css; }; };
        });

        pkgs = import nixpkgs { inherit system; overlays = [ pkgsLib ]; };
      in
      {
        lib = lib // {
          pkgsLib = import ./pkgs-lib.nix { inherit pkgs; utils = utils // { inherit (lib) tags css; }; };
        };

        overlays = {
          inherit pkgsLib;
        };

        apps = with flakeUtils.lib; {
          site = mkApp {
            drv = import ./examples/site.nix { inherit lib pkgs; };
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
