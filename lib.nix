let
  inherit (builtins) isAttrs isList map;
in
{
  mapAttrsToList = f: attrs: map (name: f name attrs.${name}) (builtins.attrNames attrs);
  concatStrings = builtins.concatStringsSep "";
  genAttrs = f: names: builtins.listToAttrs (map (n: { name = n; value = (f n); }) names);
} // builtins
