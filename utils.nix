let
  inherit (builtins) isAttrs isList map any concatMap concatStringsSep listToAttrs;

  mapAttrsToList = f: attrs: map (name: f name attrs.${name}) (builtins.attrNames attrs);
in
{
  inherit mapAttrsToList;

  recursiveAttrPaths = set:
    let
      flattenIfHasList = x:
        if (isList x) && (any isList x)
        then concatMap flattenIfHasList x
        else [ x ];

      recurse = path: set:
        let
          g =
            name: value:
            if isAttrs value
            then recurse (path ++ [ name ]) value
            else path ++ [ name ];
        in
        mapAttrsToList g set;
    in
    flattenIfHasList (recurse [ ] set);

  concatStrings = concatStringsSep "";
  genAttrs = f: names: listToAttrs (map (n: { name = n; value = (f n); }) names);
} // builtins
