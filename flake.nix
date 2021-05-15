{
  inputs = {
    nixpkgsLib.url = "github:divnix/nixpkgs.lib";
  };

  outputs = { self, nixpkgsLib }:
    let
      lib = nixpkgsLib.lib // {
        recursiveAttrPaths = set:
          let
            flattenIfHasList = x:
              if (lib.isList x) && (lib.any lib.isList x)
              then lib.concatMap flattenIfHasList x
              else [ x ];

            recurse = path: set:
              let
                g =
                  name: value:
                  if lib.isAttrs value
                  then recurse (path ++ [ name ]) value
                  else path ++ [ name ];
              in
              lib.mapAttrsToList g set;
          in
          flattenIfHasList (recurse [ ] set);
      };

      tags = import ./tags.nix { format = false; inherit lib; };
      pkgsLib = (final: prev: {
        htmlNix = import ./pkgs-lib.nix { inherit lib; pkgs = prev; };
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
