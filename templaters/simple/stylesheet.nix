{
  css,
  l,
  ...
}: let
  colors = {
    light = rec {
      fg = "#000";
      bg = "#faf9f6";
      code-bg = fg;
      code-fg = bg;
      link = "#1f51ff";
      link-visited = "#9d00ff";
    };
    dark = rec {
      fg = "#eee";
      bg = "#111";
      code-bg = "#333";
      code-fg = fg;
      link = "#007fff";
      link-visited = "#bf40bf";
    };
  };
  headers = extra:
    l.genAttrs
    (l.map l.toString (l.range 1 6))
    (n: "h${l.toString n}${extra}");
in
  css [
    (css (
      l.mapAttrs'
      (
        name: value:
          l.nameValuePair
          value
          {
            content = ''"${l.concatStrings (l.map (_: "#") (l.range 1 (l.toInt name)))} "'';
          }
      )
      (headers ":before")
    ))
    (css (
      l.mapAttrs'
      (_: value: l.nameValuePair value {content = ''""'';})
      (headers ".nohashtag:before")
    ))
    (css {
      body = {
        font-family = ["sans-serif"];
        color = colors.light.fg;
        background = colors.light.bg;
        max-width = "650px";
        margin = "40px auto";
        padding = "0 10px";
      };
      "pre,code" = {
        font-family = ["monospace"];
        background = colors.light.code-bg;
        color = colors.light.code-fg;
        padding = "4px";
        border-radius = "4px";
      };
      "pre code" = {
        padding = 0;
        border-radius = 0;
      };
      a = {
        color = colors.light.link;
        text-decoration = "none";
      };
      "a:hover".text-decoration = "underline";
      "a:visited".color = colors.light.link-visited;
      "a.novisited:visited".color = colors.light.link;
      "h1,h2,h3".line-height = "1.2";
    })
    (css.media "prefers-color-scheme: dark" {
      body = {
        color = colors.dark.fg;
        background = colors.dark.bg;
      };
      "pre,code" = {
        color = colors.dark.code-fg;
        background = colors.dark.code-bg;
      };
      a.color = colors.dark.link;
      "a:visited".color = colors.dark.link-visited;
      "a.novisited:visited".color = colors.dark.link;
    })
  ]
