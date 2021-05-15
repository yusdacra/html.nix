{
  outputs = { self }:
    let
      utils = import ./utils.nix;

      tags = import ./tags.nix { format = false; inherit utils; };
      pkgsLib = (final: prev: {
        htmlNix = import ./pkgs-lib.nix { pkgs = prev; inherit utils; };
      });
    in
    {
      lib = {
        inherit tags;
      };

      overlays = {
        inherit pkgsLib;
      };

      examples = {
        tags = import ./examples/tags.nix tags;
        serve = import ./examples/serve.nix { inherit tags pkgsLib; }; # needs --impure
      };
    };
}
