topArgs: {
  perSystem = {config, ...}: let
    html-nix = config.html-nix.lib;
    siteServe = html-nix.mkServeFromSite (html-nix.mkSiteFrom {
      src = ./site;
      templater = topArgs.config.html-nix.lib.templaters.simple;
      local = true;
    });
  in {
    apps.site.program = "${siteServe}/bin/serve";
  };
}
