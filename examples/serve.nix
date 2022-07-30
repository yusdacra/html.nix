{
  tags,
  pkgs,
}:
with pkgs.htmlNix; let
  index = with tags;
    html [
      (body [
        (p "Hello world!")
        (mkLink "./ex.html" "say bye")
      ])
    ];

  ex = with tags;
    html [
      (body [
        (p "Bye world!")
        (mkLink "./index.html" "go back")
      ])
    ];

  site = {
    "index.html" = index;
    "ex.html" = ex;
  };
in
  mkServeFromSite site
