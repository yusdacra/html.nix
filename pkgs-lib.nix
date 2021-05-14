{ lib ? import ./lib.nix, pkgs }:
let pkgBin = name: "${pkgs.${name}}/bin/${name}"; in
{
  mkServePathScript = path: pkgs.writeScriptBin "serve" { } ''
    #!${pkgBin "bash"}
    ${pkgBin "miniserve"} --index index.html ${path}
  '';
}
