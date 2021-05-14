{
  inputs = { };

  outputs = { self }:
    let
      tagsPath = ./tags.nix;
      libPath = ./lib.nix;
      pkgsLibPath = ./pkgs-lib.nix;

      lib = import libPath;
    in
    {
      lib = {
        inherit tagsPath libPath pkgsLibPath;

        tags = import tagsPath { format = true; inherit lib; };
        core = lib;
      };

      overlays = {
        pkgsLib = (final: prev: {
          htmlNix = import pkgsLibPath { inherit lib; pkgs = prev; };
        });
      };
    };
}
