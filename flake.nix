{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    parts.url = "github:hercules-ci/flake-parts";
    examples.url = "path:./examples";
  };

  outputs = inp:
    inp.parts.lib.mkFlake {inputs = inp;} {
      debug = true;
      systems = ["x86_64-linux"];
      flake = {
        flakeModule = ./default.nix;
        inherit (inp.examples) apps;
      };
    };
}
