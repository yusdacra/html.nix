{
  config,
  lib,
  ...
}: let
  l = lib // builtins;
  t = l.types;
  inherit (config.html-nix.lib) html css;

  func = ctx: let
    stylesheets = l.map html.mkStylesheet ["${ctx.baseurl}/site.css"];
    stylesheet = import ./stylesheet.nix {inherit css l;};

    renderPost = post:
      with html;
        article [
          (h1 {inherit (post) id;} post.displayName)
          (
            l.optionalString
            (post.date != null)
            (h4 {class = "nohashtag";} ("date: " + post.date))
          )
          post.content
        ];

    mkPage = {
      content,
      titleStr ? ctx.config.title,
    }:
      with html; ''
        <!DOCTYPE html>
        ${html.html [
          (head (stylesheets
            ++ [
              (title titleStr)
              (meta {
                name = "viewport";
                content = "width=device-width, initial-scale=1";
              })
            ]))
          (body ''
            ${script "0"}
            ${div (l.flatten [
              navBar
              (hr {})
              content
            ])}
          '')
        ]}
      '';

    navBar = with html;
      nav (
        [
          (a {
            href = "${ctx.baseurl}/";
            class = "novisited";
          } "home")
        ]
        ++ (
          l.map
          (
            page:
              " "
              + (
                a {
                  href = "${ctx.baseurl}/${page.id}/";
                  class = "novisited";
                }
                page.displayName
              )
          )
          ctx.pages
        )
      );

    mkPostsLinks = posts:
      with html;
        l.singleton
        (ul (
          l.map
          (
            post:
              li (
                a {href = "${ctx.baseurl}/${post.id}";}
                (
                  if post.date != null
                  then "${post.date} - ${post.displayName}"
                  else post.displayName
                )
              )
          )
          posts
        ));
    postsLinksWithDate = mkPostsLinks (l.filter (p: p.date != null) ctx.posts);
    postsLinksWithoutDate = mkPostsLinks (l.filter (p: p.date == null) ctx.posts);

    postsSectionContent =
      [(html.h1 "posts")]
      ++ postsLinksWithDate
      ++ [(html.h2 "miscellaneous")]
      ++ postsLinksWithoutDate;

    postsRendered = l.listToAttrs (
      l.map
      (post:
        l.nameValuePair post.id {
          content = renderPost post;
          name = post.displayName;
        })
      ctx.posts
    );
    pagesRendered = l.listToAttrs (
      l.map
      (page:
        l.nameValuePair page.id {
          content = page.content;
          name = page.displayName;
        })
      ctx.pages
    );

    indexPage = mkPage {
      content = ctx.indexContent or postsSectionContent;
    };
  in {
    inherit ctx stylesheets mkPage stylesheet postsSectionContent;

    site =
      ctx.site
      // {
        "index.html" = indexPage;
        "posts"."index.html" = mkPage {
          content = postsSectionContent;
          titleStr = "posts - ${ctx.config.title}";
        };
        "404.html" = mkPage {
          content = html.h1 {class = "nohashtag";} "404 - page not found";
          titleStr = "page not found - ${ctx.config.title}";
        };
        "site.css" = stylesheet;
      }
      // (
        l.mapAttrs
        (
          name: value: {
            "index.html" = mkPage {
              content = value.content;
              titleStr = "${value.name} - ${ctx.config.title}";
            };
          }
        )
        (pagesRendered // postsRendered)
      )
      // l.optionalAttrs (ctx ? resources) {inherit (ctx) resources;};
  };
in {
  options = {
    html-nix.lib.templaters.simple = l.mkOption {
      type = t.uniq (t.functionTo t.attrs);
    };
  };
  config = {
    html-nix.lib.templaters.simple = func;
  };
}
