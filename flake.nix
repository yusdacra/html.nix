{
  inputs = {
    nixpkgsLib.url = "github:divnix/nixpkgs.lib";
  };

  outputs = { self, nixpkgsLib }:
    let
      lib = nixpkgsLib.lib;
      tags = import ./tags.nix { format = true; inherit lib; };
    in
    {
      lib = {
        inherit tags;
      };

      overlays = {
        pkgsLib = (final: prev: {
          htmlNix = import ./pkgs-lib.nix { inherit lib; pkgs = prev; };
        });
      };

      example = import ./example.nix tags;
    };
}
