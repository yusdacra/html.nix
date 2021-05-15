{ utils, posts, pkgs, config, ... }@context:
let
  inherit (utils) readFile mapAttrsToList tags fetchGit;
  inherit (pkgs.lib) flatten;

  renderPost = name: value: with tags; [
    (a { href = "#${name}"; class = "postheader"; } (h3 { id = name; } ("## " + name)))
    (readFile value)
  ];

  allPosts = flatten (mapAttrsToList renderPost posts);
in
{
  "index.html" = with tags;
    html [
      (head [
        (title config.title)
        (mkStylesheet "https://unpkg.com/purecss@2.0.6/build/pure-min.css")
        (mkStylesheet "https://unpkg.com/purecss@2.0.6/build/grids-responsive-min.css")
        (mkStylesheet "css/mine.css")
        (meta { name = "viewport"; content = "width=device-width, initial-scale=1"; })
      ])
      (body [
        (div { class = "about"; } [
          (a { href = "#About"; class = "postheader"; } (h1 "# About"))
          (p config.about)
        ])
        (div { class = "posts"; } ([
          (a { href = "#Posts"; class = "postheader"; } (h1 "# Posts"))
        ] ++ allPosts))
      ])
    ];

  css = {
    "mine.css" = ''
      a.postheader,a.postheader:hover {
        color: inherit;
        text-decoration: underline;
      }
      div.posts {
        margin-top: 5%;
        margin-bottom: 5%;
        margin-left: 20%;
        margin-right: 10%;
      }
      div.about {
        position: -webkit-sticky;
        position: sticky;
        top: 0;
        margin-left: 3%;
      }
    '';
  };
}
