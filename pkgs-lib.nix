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
  mkSiteFrom = { src, templater, local ? false }:
    let
      inherit (utils) readDir readFile fromTOML mapAttrsToList sort elemAt;
      inherit (pkgs.lib) nameValuePair head splitString pipe removeSuffix mapAttrs';

      postsRendered =
        let path = src + "/posts"; in
        pipe (readDir path) [
          (mapAttrsToList (name: _:
            nameValuePair
              (head (splitString "." name))
              (readFile (parseMarkdown name (readFile (path + "/${name}"))))
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
      pagesRendered =
        let path = src + "/pages"; in
        mapAttrs'
          (name: _:
            nameValuePair
              (head (splitString "." name))
              (readFile (parseMarkdown name (readFile (path + "/${name}"))))
          )
          (readDir path);
      siteConfig = fromTOML (readFile (src + "/config.toml"));
      baseurl = if local then "http://127.0.0.1:8080" else siteConfig.baseurl or (throw "Need baseurl");

      context = {
        inherit utils pkgs baseurl;
        config = siteConfig;
        posts = postsRendered;
        pages = pagesRendered;
        site = {
          "robots.txt" = ''
            User-agent: *
            Allow: /
            Sitemap: ${baseurl}/sitemap.xml
          '';
        };
      };
    in
    (templater context).site;
}
