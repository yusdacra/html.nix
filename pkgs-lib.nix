{ utils, pkgs }:
let pkgBin = name: "${pkgs.${name}}/bin/${name}"; in
{
  mkServePathScript = path: pkgs.writeScriptBin "serve" ''
    #!${pkgs.stdenv.shell}
    ${pkgBin "miniserve"} --index index.html ${path}
  '';

  mkSitePath = site:
    let
      inherit (utils) recursiveAttrPaths concatStringsSep map;
      inherit (pkgs.lib) mapAttrsRecursive init last getAttrFromPath;

      fileAttrPaths = recursiveAttrPaths site;
      texts = mapAttrsRecursive (path: value: pkgs.writeText (concatStringsSep "-" path) value) site;
      mkCreateFileCmd = path: value: let p = concatStringsSep "/" (init path); in "mkdir -p $out/${p} && ln -s ${value} $out/${p}/${last path}";
      createFileCmds = map (path: mkCreateFileCmd path (getAttrFromPath path texts)) fileAttrPaths;
    in
    pkgs.runCommand "site-path" { } ''
      mkdir -p $out
      ${concatStringsSep "\n" createFileCmds}
    '';
}
