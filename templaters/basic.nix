{
  config,
  lib,
  ...
}: let
  l = lib // builtins;
  t = l.types;
  inherit (config.html-nix.lib) html css;

  func = ctx: let
    stylesheets = l.map html.mkStylesheet [
      "https://unpkg.com/purecss@3.0.0/build/pure-min.css"
      "https://unpkg.com/purecss@3.0.0/build/grids-responsive-min.css"
      "${ctx.baseurl}/site.css"
    ];

    parsePostName = name: let
      parts = l.splitString "_" name;
      id = l.elemAt parts 1;
      date = l.elemAt parts 0;
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
      with html;
        article [
          (a {
            href = "#${id}";
            class = "postheader";
          } (h2 {inherit id;} id))
          (h3 ("date: " + date))
          value
        ];

    pagesSection = with html;
      [
        (div {class = "pure-u-1";} (a {
          href = "${ctx.baseurl}/";
          class = "pagelink";
        } "home"))
      ]
      ++ (l.map
        (name:
          div {class = "pure-u-1";} (a {
              href = "${ctx.baseurl}/${name}/";
              class = "pagelink";
            }
            name))
        (l.mapAttrsToList (name: _: name) ctx.pages))
      ++ [
        (div {class = "pure-u-1";} (a {
          href = "${ctx.baseurl}/posts/";
          class = "pagelink";
        } "posts"))
      ];

    postsLinks = with html;
      l.singleton
      (ul (
        l.map
        (
          post:
            li (
              a {href = "${ctx.baseurl}/${post.name}";}
              (parsePostName post.name).formatted
            )
        )
        ctx.posts
      ));

    postsSectionContent = with html;
      [
        (a {
          href = "#posts";
          class = "postheader";
        } (h1 "posts"))
      ]
      ++ postsLinks;

    sidebarSection = l.optionalString ((l.length pagesSection) > 0) (
      with html;
        nav {class = "sidebar";} [
          (div {class = "pure-g";} pagesSection)
        ]
    );

    mkPage = content:
      with html; ''
        <!DOCTYPE html>
        ${html.html [
          (head (stylesheets
            ++ [
              (title ctx.config.title)
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

    indexPage = mkPage (ctx.indexContent or postsSectionContent);

    pagesAndPosts =
      ctx.pages
      // l.listToAttrs (
        map (post: l.nameValuePair post.name (renderPost post)) ctx.posts
      );

    stylesheet = let
      marginMobile = {
        margin-left = "3%";
        margin-right = "3%";
      };
    in
      css [
        (css (
          (
            l.mapAttrs'
            (
              name: value:
                l.nameValuePair
                value
                {
                  content = "\"${l.concatStrings (l.map (_: "#") (l.range 1 (l.toInt name)))} \"";
                }
            )
            (
              l.genAttrs
              (l.map l.toString (l.range 1 6))
              (n: "h${l.toString n}:before")
            )
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
        (css.media "max-width: 48em" {
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
      ctx.site
      // {
        "index.html" = indexPage;
        "posts"."index.html" = mkPage postsSectionContent;
        "404.html" = mkPage (html.h1 "No such page");
        "site.css" = stylesheet;
      }
      // (l.mapAttrs (name: value: {"index.html" = mkPage value;}) pagesAndPosts)
      // l.optionalAttrs (ctx ? resources) {inherit (ctx) resources;};
  };
in {
  options = {
    html-nix.lib.templaters.basic = l.mkOption {
      type = t.functionTo t.attrs;
    };
  };
  config = {
    html-nix.lib.templaters.basic = func;
  };
}
