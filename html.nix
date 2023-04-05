{lib, ...}: let
  l = lib // builtins;

  evalAttrs = attrs:
    l.concatStrings
    (
      l.mapAttrsToList
      (name: value: " ${name}=\"${value}\"")
      attrs
    );
  evalChildren = children:
    if l.isList children
    then l.concatStrings children
    else children;
  tag = name: maybeAttrs:
    if l.isAttrs maybeAttrs
    then (children: "<${name}${evalAttrs maybeAttrs}>${evalChildren children}</${name}>")
    else tag name {} maybeAttrs;
  noChildrenTag = name: attrs: "<${name} ${evalAttrs attrs}>";

  tagsToGen =
    (l.map (n: "h${toString n}") (l.range 1 6))
    ++ ["ul" "li" "html" "head" "body" "div" "p"]
    ++ ["a" "title" "code" "pre" "nav" "article" "script"];
  tags = l.genAttrs tag tagsToGen;

  noChildrenTagsToGen = ["link" "meta"];
  noChildrenTags = l.genAttrs noChildrenTag noChildrenTagsToGen;
in {
  options = {
    html-nix.lib.html = l.mkOption {
      type = l.types.raw;
    };
  };
  config = {
    html-nix.lib.html =
      tags
      // noChildrenTags
      // {
        inherit tag;
        mkLink = url: tags.a {href = url;};
        mkStylesheet = url:
          noChildrenTags.link {
            rel = "stylesheet";
            href = url;
          };
      };
  };
}
