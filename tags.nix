{ utils }:
let
  inherit (utils) concatStrings mapAttrsToList genAttrs isAttrs isList range toString;

  evalAttrs = attrs: concatStrings (mapAttrsToList (name: value: " ${name}=\"${value}\"") attrs);
  evalChildren = children: if isList children then concatStrings children else children;
  tag = name: maybeAttrs:
    if isAttrs maybeAttrs
    then (children: "<${name}${evalAttrs maybeAttrs}>\n  ${evalChildren children}\n</${name}>\n")
    else tag name { } maybeAttrs;

  tagsToGen = [ "html" "head" "body" "div" "p" "a" "title" "meta" "code" "pre" ] ++ (map (n: "h${toString n}") (range 1 6));
  tags = genAttrs tag tagsToGen;
in
tags // {
  inherit tag;
  link = url: tags.a { href = url; };
}
