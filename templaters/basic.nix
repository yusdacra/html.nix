{ utils, posts, pkgs, config, ... }@context:
let
  inherit (utils) readFile mapAttrsToList;
  inherit (pkgs.lib) flatten;

  renderPost = name: value: with utils.tags; [
    (h2 ("# " + name))
    (readFile value)
  ];

  allPosts = flatten (mapAttrsToList renderPost posts);
in
{
  "index.html" = with utils.tags;
    html [
      (head [
        (title config.title)
      ])
      (body allPosts)
    ];
}
