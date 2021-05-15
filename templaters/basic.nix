{ utils, posts, pkgs, config, ... }@context:
let
  inherit (utils) readFile mapAttrsToList tags fetchGit map;
  inherit (pkgs.lib) flatten optional length;

  stylesheets = map tags.mkStylesheet [ "https://unpkg.com/purecss@2.0.6/build/pure-min.css" "https://unpkg.com/purecss@2.0.6/build/grids-responsive-min.css" "mine.css" ];

  renderPost = name: value: with tags; article [
    (a { href = "#${name}"; class = "postheader"; } (h3 { id = name; } ("## " + name)))
    (readFile value)
  ];
  allPosts = flatten (mapAttrsToList renderPost posts);
  pages =
    mapAttrsToList
      (name: relPath: tags.div { class = "pure-u-1"; } (tags.a { href = "./${relPath}"; class = "postheader"; } name))
      (config.pages or { });

  postsSectionContent = with tags; [
    (a { href = "#posts"; class = "postheader"; } (h1 "# posts"))
  ] ++ allPosts;

  sidebarSection = optional ((length pages) > 0) (
    with tags; nav { class = "sidebar"; } ([
      (a { href = "#pages"; class = "postheader"; } (h1 "# pages"))
      (div { class = "pure-g"; } pages)
    ])
  );

  mkPage = content: with tags;
    html [
      (head (stylesheets ++ [
        (title config.title)
        (meta { name = "viewport"; content = "width=device-width, initial-scale=1"; })
      ]))
      (body (sidebarSection ++ [ (div { class = "content"; } content) ]))
    ];

  stylesheet =
    with utils.css;
    css [
      (css {
        body = {
          font-family = [ "Raleway" "Helvetica" "Arial" "sans-serif" ];
        };
        code = {
          font-family = [ "Iosevka Term" "Iosevka" "monospace" ];
          background = "#000000cc";
          color = "#eeeeee";
        };
        "a.postheader,a.postheader:hover" = {
          color = "inherit";
          text-decoration = "none";
        };
        "a.postheader:hover" = {
          text-decoration = "underline";
        };
        "div.content" = {
          margin-top = "5%";
          margin-bottom = "5%";
          margin-left = "20%";
          margin-right = "10%";
        };
        "nav.sidebar" = {
          position = "fixed";
          top = 0;
          margin-left = "3%";
          z-index = 1000;
        };
      })
      (media "max-width: 48em" {
        "nav.sidebar" = {
          position = "relative";
          margin-top = "5%";
          margin-left = "3%";
          margin-right = "3%";
        };
        "div.content" = {
          margin-top = 0;
          margin-left = "3%";
          margin-right = "3%";
        };
      })
    ];
in
{
  inherit stylesheets sidebarSection mkPage stylesheet;

  site = {
    "index.html" = mkPage postsSectionContent;
    "mine.css" = stylesheet;
  };
}
