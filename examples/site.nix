{
  perSystem = {config, ...}: let
    html-nix = config.html-nix;
    siteServe = html-nix.mkServeFromSite (html-nix.mkSiteFrom {
      src = ./site;
      templater = html-nix.lib.templaters.basic;
      local = true;
    });
  in {
    apps.site.program = "${siteServe}/bin/serve";
  };
}
