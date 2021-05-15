{ utils, posts, pkgs, config, ... }@context:
let
  inherit (utils) readFile mapAttrsToList tags fetchGit;
  inherit (pkgs.lib) flatten;

  skeleton = fetchGit {
    url = "https://github.com/dhg/Skeleton.git";
    rev = "88f03612b05f093e3f235ced77cf89d3a8fcf846";
  };

  renderPost = name: value: with tags; [
    (a { href = "#${name}"; class = "postheader"; } (h4 { id = name; } ("## " + name)))
    (readFile value)
  ];

  allPosts = flatten (mapAttrsToList renderPost posts);
in
{
  "index.html" = with tags;
    html [
      (head [
        (title config.title)
        (mkStylesheet "css/normalize.css")
        (mkStylesheet "css/skeleton.css")
        (mkStylesheet "css/mine.css")
      ])
      (body [
        (div { class = "container"; style = "margin-top: 5%; margin-bottom: 5%;"; } [
          (div { class = "column"; } [
            (div { class = "twelve columns"; } [
              (a { href = "#About"; class = "postheader"; } (h1 "# About"))
              (p config.about)
            ])
            (div { class = "twelve columns"; } ([
              (a { href = "#Posts"; class = "postheader"; } (h1 "# Posts"))
            ] ++ allPosts))
          ])
        ])
      ])
    ];

  css = {
    "normalize.css" = readFile "${skeleton}/css/normalize.css";
    "skeleton.css" = readFile "${skeleton}/css/skeleton.css";
    "mine.css" = ''
      a.postheader {
        color: inherit;
        text-decoration: underline;
      }
      a.postheader:hover {
        color: inherit;
        text-decoration: underline;
      }
    '';
  };
}
