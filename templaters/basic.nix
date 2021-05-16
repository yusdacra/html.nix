{ utils, posts, pkgs, config, ... }@context:
let
  inherit (utils) readFile mapAttrsToList tags fetchGit map elemAt;
  inherit (pkgs.lib) optional length splitString;

  stylesheets = map tags.mkStylesheet [
    "https://unpkg.com/purecss@2.0.6/build/pure-min.css"
    "https://unpkg.com/purecss@2.0.6/build/grids-responsive-min.css"
    "mine.css"
  ];

  renderPost = { name, value }:
    let
      parts = splitString "_" name;
      id = elemAt parts 1;
    in
    with tags; article [
      (a { href = "#${id}"; class = "postheader"; } (h3 { inherit id; } ("## " + id)))
      (h6 ("date: " + (elemAt parts 0)))
      (readFile value)
    ];

  pages =
    mapAttrsToList
      (name: relPath: tags.div { class = "pure-u-1"; } (tags.a { href = "./${relPath}"; class = "postheader"; } name))
      (config.pages or { });

  postsSectionContent = with tags; [
    (a { href = "#posts"; class = "postheader"; } (h1 "# posts"))
  ] ++ (map renderPost posts);

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
    let
      marginMobile = {
        margin-left = "3%";
        margin-right = "3%";
      };
    in
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
        } // marginMobile;
        "div.content" = {
          margin-top = 0;
        } // marginMobile;
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
