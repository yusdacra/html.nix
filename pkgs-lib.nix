{ lib, pkgs }:
let pkgBin = name: "${pkgs.${name}}/bin/${name}"; in
{
  mkServePathScript = path: pkgs.writeScriptBin "serve" ''
    #!${pkgs.stdenv.shell}
    ${pkgBin "miniserve"} --index index.html ${path}
  '';

  mkSitePath = site:
    let
      fileAttrPaths = lib.recursiveAttrPaths site;
      texts = lib.mapAttrsRecursive (path: value: pkgs.writeText (lib.concatStringsSep "-" path) value) site;
      mkCreateFileCmd = path: value: let p = lib.concatStringsSep "/" (lib.init path); in "mkdir -p $out/${p} && ln -s ${value} $out/${p}/${lib.last path}";
      createFileCmds = map (path: mkCreateFileCmd path (lib.getAttrFromPath path texts)) fileAttrPaths;
    in
    pkgs.runCommand "site-path" { } ''
      mkdir -p $out
      ${lib.concatStringsSep "\n" createFileCmds}
    '';
}
