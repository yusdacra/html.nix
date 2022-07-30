{utils}: let
  inherit (utils) mapAttrsToList concatStringsSep isList toString map;

  evalCssValue = value:
    if isList value
    then concatStringsSep ", " (map toString value)
    else toString value;
  evalInner = inner: concatStringsSep " " (mapAttrsToList (name: value: "${name}: ${evalCssValue value};") inner);
  css = maybeAttrs:
    if isList maybeAttrs
    then concatStringsSep " " maybeAttrs
    else concatStringsSep " " (mapAttrsToList (name: inner: "${name} { ${evalInner inner} }") maybeAttrs);
in {
  inherit css;

  media = rule: inner: ''
    @media (${rule}) { ${css inner} }
  '';
}
