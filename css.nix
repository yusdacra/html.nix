{lib, ...}: let
  l = lib // builtins;
  t = l.types;

  evalCssValue = value:
    if l.isList value
    then l.concatStringsSep ", " (l.map toString value)
    else l.toString value;
  evalInner = inner:
    l.concatStringsSep
    " "
    (
      l.mapAttrsToList
      (name: value: "${name}: ${evalCssValue value};")
      inner
    );
  eval = maybeAttrs:
    if l.isList maybeAttrs
    then l.concatStringsSep " " maybeAttrs
    else
      l.concatStringsSep
      " "
      (
        l.mapAttrsToList
        (name: inner: "${name} { ${evalInner inner} }")
        maybeAttrs
      );
  css = {
    __functor = self: arg: eval arg;
    media = rule: inner: ''
      @media (${rule}) { ${eval inner} }
    '';
  };
in {
  options = {
    html-nix.lib.css = l.mkOption {
      type = t.functionTo t.str;
    };
  };
  config = {
    html-nix.lib.css = css;
  };
}
