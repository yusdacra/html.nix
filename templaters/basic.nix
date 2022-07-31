{
  utils,
  posts,
  pkgs,
  config,
  pages,
  site,
  baseurl,
  ...
} @ context: let
  inherit (utils) readFile mapAttrsToList mapAttrs tags fetchGit map elemAt foldl' concatStrings genAttrs toString;
  inherit (pkgs.lib) optionalString optionalAttrs optional length splitString nameValuePair toInt range mapAttrs' singleton;
  inherit (builtins) listToAttrs;

  stylesheets = map tags.mkStylesheet [
    "https://unpkg.com/purecss@2.0.6/build/pure-min.css"
    "https://unpkg.com/purecss@2.0.6/build/grids-responsive-min.css"
    "${baseurl}/site.css"
  ];

  parsePostName = name: let
    parts = splitString "_" name;
    id = elemAt parts 1;
    date = elemAt parts 0;
  in {
    inherit id date;
    formatted = "${date} - ${id}";
  };

  renderPost = {
    name,
    value,
  }: let
    parsed = parsePostName name;
    inherit (parsed) id date;
  in
    with tags;
      article [
        (a {
          href = "#${id}";
          class = "postheader";
        } (h2 {inherit id;} id))
        (h3 ("date: " + date))
        value
      ];

  pagesSection =
    [
      (tags.div {class = "pure-u-1";} (tags.a {
        href = "${baseurl}/";
        class = "pagelink";
      } "home"))
    ]
    ++ (map
      (name:
        tags.div {class = "pure-u-1";} (tags.a {
            href = "${baseurl}/${name}/";
            class = "pagelink";
          }
          name))
      (mapAttrsToList (name: _: name) pages))
    ++ [
      (tags.div {class = "pure-u-1";} (tags.a {
        href = "${baseurl}/posts/";
        class = "pagelink";
      } "posts"))
    ];

  postsRendered = map renderPost posts;

  postsLinks = with tags;
    singleton
    (ul (
      map
      (
        post:
          li (
            a {href = "${baseurl}/${post.name}";}
            (parsePostName post.name).formatted
          )
      )
      posts
    ));

  postsSectionContent = with tags;
    [
      (a {
        href = "#posts";
        class = "postheader";
      } (h1 "posts"))
    ]
    ++ postsLinks;

  sidebarSection = optionalString ((length pagesSection) > 0) (
    with tags;
      nav {class = "sidebar";} [
        (div {class = "pure-g";} pagesSection)
      ]
  );

  mkPage = content:
    with tags; ''
      <!DOCTYPE html>
      ${html [
        (head (stylesheets
          ++ [
            (title config.title)
            (meta {
              name = "viewport";
              content = "width=device-width, initial-scale=1";
            })
          ]))
        (body ''
          ${script "0"}
          ${sidebarSection}
          ${div {class = "content";} content}
        '')
      ]}
    '';

  indexPage = mkPage (context.indexContent or postsSectionContent);

  pagesAndPosts =
    pages
    // listToAttrs (
      map (post: nameValuePair post.name (renderPost post)) posts
    );

  stylesheet = with utils.css; let
    marginMobile = {
      margin-left = "3%";
      margin-right = "3%";
    };
  in
    css [
      (css (
        (
          mapAttrs'
          (name: value: nameValuePair value {content = "\"${concatStrings (map (_: "#") (range 1 (toInt name)))} \"";})
          (genAttrs (n: "h${toString n}:before") (map toString (range 1 6)))
        )
        // {
          body = {
            font-family = ["Raleway" "Helvetica" "Arial" "sans-serif"];
            background = "#111111";
            color = "#eeeeee";
          };
          pre = {
            font-family = ["Iosevka Term" "Iosevka" "monospace"];
            background = "#171A21";
            color = "#eeeeee";
          };
          "a,a:hover" = {
            color = "#ffd814";
            text-decoration = "none";
          };
          "a:hover" = {
            text-decoration = "underline";
          };
          "a.postheader,a.postheader:hover" = {
            color = "#fc6711";
          };
          "a.pagelink,a.pagelink:hover" = {
            color = "#ffd814";
          };
          "div.content" = {
            margin-top = "5%";
            margin-bottom = "5%";
            margin-left = "20%";
            margin-right = "25%";
          };
          "nav.sidebar" = {
            position = "fixed";
            margin-left = "3%";
            padding-top = 0;
            z-index = 1000;
          };
        }
      ))
      (media "max-width: 48em" {
        "nav.sidebar" =
          {
            position = "relative";
            margin-top = "5%";
          }
          // marginMobile;
        "div.content" =
          {
            margin-top = 0;
          }
          // marginMobile;
      })
    ];
in {
  inherit stylesheets sidebarSection mkPage stylesheet;

  site =
    site
    // {
      "index.html" = indexPage;
      "posts"."index.html" = mkPage postsSectionContent;
      "404.html" = mkPage (tags.h1 "No such page");
      "site.css" = stylesheet;
    }
    // (mapAttrs (name: value: {"index.html" = mkPage value;}) pagesAndPosts)
    // optionalAttrs (context ? resources) {inherit (context) resources;};
}
