{
  inputs = { };

  outputs = { self }:
    let
      tagsPath = ./tags.nix;
      libPath = ./lib.nix;

      lib = import libPath;
    in
    {
      lib = {
        inherit tagsPath libPath;

        tags = import tagsPath { format = true; inherit lib; };
        core = lib;
      };
    };
}
