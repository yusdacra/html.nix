topArgs: {
  perSystem = {config, ...}: let
    html-nix = config.html-nix.lib;
    siteServe = html-nix.mkServeFromSite (html-nix.mkSiteFrom {
      src = ./site;
      templater = topArgs.config.html-nix.lib.templaters.simple;
      local = true;
      config = {
        baseurl = "http://127.0.0.1:8080";
        title = "test site";
      };
    });
  in {
    apps.site.program = "${siteServe}/bin/serve";
  };
}
