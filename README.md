HTML utilities and SSG in Nix. Checkout [examples](./examples).

## Examples

Run site templating example with `nix build --impure github:yusdacra/html.nix#examples.siteServe && ./result/bin/serve`.

## Usage

Get it as a flake:
```
  inputs.htmlNix.url = "github:yusdacra/html.nix";
```