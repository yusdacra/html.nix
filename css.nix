{ utils }:
let
  inherit (utils) mapAttrsToList concatStringsSep isList toString map;

  evalCssValue = value: if isList value then concatStringsSep ", " (map toString value) else toString value;
  evalInner = inner: concatStringsSep "\n" (mapAttrsToList (name: value: "${name}: ${evalCssValue value};") inner);
  css = maybeAttrs:
    if isList maybeAttrs
    then concatStringsSep "\n" maybeAttrs
    else concatStringsSep "\n" (mapAttrsToList (name: inner: "${name} {\n${evalInner inner}\n}") maybeAttrs);
in
{
  inherit css;

  media = rule: inner: ''
    @media (${rule}) {
        ${css inner}
    }
  '';
}
