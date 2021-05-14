{ format ? false, lib ? import ./lib.nix }:
with lib; let
  fmt = if format then "\n  " else "";

  evalAttrs = attrs: concatStrings (mapAttrsToList (name: value: " ${name}=\"${value}\"") attrs);
  evalChildren = children: if isList children then concatStrings children else children;
  tag = name: maybeAttrs:
    if isAttrs maybeAttrs
    then (children: "<${name}${evalAttrs maybeAttrs}>${fmt}${evalChildren children}${fmt}</${name}>")
    else tag name { } maybeAttrs;

  tags = (genAttrs tag [ "html" "head" "body" "div" "p" "a" ]);
in
tags // {
  inherit tag;
  link = url: tags.a { href = url; };
}
