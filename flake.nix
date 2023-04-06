{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inp:
    inp.parts.lib.mkFlake {inputs = inp;} {
      debug = true;
      systems = ["x86_64-linux"];
      imports = [
        ./default.nix
        ./examples
      ];
      flake = {
        flakeModule = ./default.nix;
      };
    };
}
