{ utils, pkgs }:
let
  pkgBin = name: "${pkgs.${name}}/bin/${name}";

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

  parseMarkdown = name: contents:
    pkgs.runCommand name { } ''
      printf "${contents}" | ${pkgBin "lowdown"} -o $out -
    '';
in
{
  inherit mkServePathScript mkSitePath parseMarkdown;

  mkServeFromSite = site: mkServePathScript (mkSitePath site);
  mkSiteFrom = { src, templater }:
    let
      inherit (utils) readDir readFile fromTOML;
      inherit (pkgs.lib) mapAttrs' nameValuePair head splitString;

      postsRendered =
        let path = src + "/posts"; in
        mapAttrs'
          (name: _:
            nameValuePair
              (head (splitString "." name))
              (parseMarkdown name (readFile (path + "/${name}")))
          )
          (readDir path);
      siteConfig = fromTOML (readFile (src + "/config.toml"));

      context = {
        inherit utils pkgs;
        config = siteConfig;
        posts = postsRendered;
      };
    in
    (templater context).site;
}
