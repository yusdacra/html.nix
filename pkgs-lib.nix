{
  lib,
  flake-parts-lib,
  ...
}: let
  l = lib // builtins;
  recursiveAttrPaths = set: let
    flattenIfHasList = x:
      if (l.isList x) && (l.any l.isList x)
      then l.concatMap flattenIfHasList x
      else [x];

    recurse = path: set: let
      g = name: value:
        if l.isAttrs value
        then recurse (path ++ [name]) value
        else path ++ [name];
    in
      l.mapAttrsToList g set;
  in
    flattenIfHasList (recurse [] set);
in {
  options = {
    perSystem =
      flake-parts-lib.mkPerSystemOption
      ({...}: {
        options = {
          html-nix.lib = {
            mkServeFromSite = l.mkOption {
              type = with l.types; functionTo package;
            };
            mkSiteFrom = l.mkOption {
              type = with l.types; functionTo attrs;
            };
            mkSitePathFrom = l.mkOption {
              type = l.types.raw;
            };
            parseMarkdown = l.mkOption {
              type = l.types.raw;
            };
          };
        };
      });
  };
  config = {
    perSystem = {pkgs, ...}: let
      pkgBin = name: "${pkgs.${name}}/bin/${name}";

      mkServePathScript = path:
        pkgs.writeScriptBin "serve" ''
          ${pkgs.nodePackages.http-server}/bin/http-server -c-1 ${path}
        '';

      mkSitePath = site: let
        convertToPath = path: value:
          if builtins.isPath value
          then value
          else pkgs.writeText (l.concatStringsSep "-" path) value;
        fileAttrPaths = recursiveAttrPaths site;
        texts = l.mapAttrsRecursive convertToPath site;
        mkCreateFileCmd = path: value: let
          p = l.concatStringsSep "/" (l.init path);
        in "mkdir -p \"$out/${p}\" && ln -s \"${value}\" \"$out/${p}/${l.last path}\"";
        createFileCmds =
          l.map
          (path: mkCreateFileCmd path (l.getAttrFromPath path texts))
          fileAttrPaths;
      in
        pkgs.runCommandLocal "site-path" {} ''
          mkdir -p $out
          ${l.concatStringsSep "\n" createFileCmds}
        '';

      parseMarkdown = name: path:
        pkgs.runCommandLocal name {} ''
          ${pkgBin "pandoc"} ${path} -f gfm -o $out
        '';
    in {
      html-nix.lib = {
        inherit parseMarkdown;
        mkSitePathFrom = mkSitePath;
        mkServeFromSite = site: mkServePathScript (mkSitePath site);
        mkSiteFrom = {
          src,
          templater,
          local ? false,
          config ? {},
        } @ args: let
          getPath = from: name:
            l.path {
              name = l.strings.sanitizeDerivationName name;
              path = "${toString from}/${name}";
            };
          indexRendered = let
            path = getPath src "index.md";
          in
            if l.pathExists path
            then l.readFile (parseMarkdown "index.html" path)
            else null;
          postsRendered = let
            path = "${toString src}/posts";
          in
            if l.pathExists path
            then
              l.pipe (l.readDir path) [
                (l.mapAttrsToList (
                  name: _: let
                    __displayName = l.head (l.splitString "." name);
                    _displayName = l.splitString "_" __displayName;
                    id = l.replaceStrings [" "] ["_"] __displayName;
                    date = l.head _displayName;
                  in {
                    inherit id;
                    displayName = l.last _displayName;
                    date =
                      if date == ""
                      then null
                      else date;
                    content = l.readFile (parseMarkdown id (getPath path name));
                  }
                ))
                (l.sort (
                  p: op: let
                    extractDate = date: l.splitString "-" date;
                    getPart = date: el: l.removeSuffix "0" (l.elemAt (extractDate date) el);
                    d = getPart p.date;
                    od = getPart op.date;
                  in
                    if p.date == null
                    then false
                    else if op.date == null
                    then true
                    else !(d 0 > od 0 && d 1 > od 1 && d 2 > od 2)
                ))
              ]
            else [];
          pagesRendered = let
            path = "${toString src}/pages";
          in
            if l.pathExists path
            then
              l.mapAttrsToList
              (
                name: _: rec {
                  displayName = l.head (l.splitString "." name);
                  id = l.replaceStrings [" "] ["_"] displayName;
                  content = l.readFile (parseMarkdown id (getPath path name));
                }
              )
              (l.readDir path)
            else [];
          baseurl =
            if local
            then "http://localhost:8080"
            else args.config.baseurl or (throw "Need baseurl");

          context =
            {
              inherit lib baseurl;
              inherit (args) config;
              posts = postsRendered;
              pages = pagesRendered;
              site = {
                "robots.txt" = ''
                  User-agent: *
                  Allow: /
                '';
              };
            }
            // l.optionalAttrs (indexRendered != null) {
              indexContent = indexRendered;
            };
        in
          (templater context).site;
      };
    };
  };
}
