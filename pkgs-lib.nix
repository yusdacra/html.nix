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
      inherit (utils) readDir readFile fromTOML mapAttrsToList sort elemAt;
      inherit (pkgs.lib) nameValuePair head splitString pipe removeSuffix;

      postsRendered =
        let path = src + "/posts"; in
        pipe (readDir path) [
          (mapAttrsToList (name: _:
            nameValuePair
              (head (splitString "." name))
              (parseMarkdown name (readFile (path + "/${name}")))
          ))
          (sort (p: op:
            let
              extractDate = name: splitString "-" (head (splitString "_" name));
              getPart = name: el: removeSuffix "0" (elemAt (extractDate name) el);
              d = getPart p.name;
              od = getPart op.name;
            in
            !(((d 0) > (od 0)) && ((d 1) > (od 1)) && ((d 2) > (od 2)))
          ))
        ];
      siteConfig = fromTOML (readFile (src + "/config.toml"));

      context = {
        inherit utils pkgs;
        config = siteConfig;
        posts = postsRendered;
      };
    in
    (templater context).site;
}
