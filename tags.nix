{utils}: let
  inherit (utils) concatStrings mapAttrsToList genAttrs isAttrs isList range toString;

  evalAttrs = attrs: concatStrings (mapAttrsToList (name: value: " ${name}=\"${value}\"") attrs);
  evalChildren = children:
    if isList children
    then concatStrings children
    else children;
  tag = name: maybeAttrs:
    if isAttrs maybeAttrs
    then (children: "<${name}${evalAttrs maybeAttrs}>${evalChildren children}</${name}>")
    else tag name {} maybeAttrs;
  noChildrenTag = name: attrs: "<${name} ${evalAttrs attrs}>";

  tagsToGen = ["html" "head" "body" "div" "p" "a" "title" "code" "pre" "nav" "article"] ++ (map (n: "h${toString n}") (range 1 6));
  tags = genAttrs tag tagsToGen;

  noChildrenTagsToGen = ["link" "meta"];
  noChildrenTags = genAttrs noChildrenTag noChildrenTagsToGen;
in
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
  }
