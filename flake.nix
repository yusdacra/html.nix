{
  outputs = { self }:
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
    in
    {
      inherit lib;

      overlays = {
        inherit pkgsLib;
      };

      examples = {
        siteServe =
          let inherit (import <nixpkgs> { overlays = [ pkgsLib ]; }) htmlNix; in
          htmlNix.mkServeFromSite (htmlNix.mkSiteFrom { src = ./examples/site; templater = lib.templaters.basic; }); # needs --impure
        tags = import ./examples/tags.nix lib.tags;
        serve = import ./examples/serve.nix { inherit (lib) tags; inherit pkgsLib; }; # needs --impure
      };
    };
}
