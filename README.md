# Usage

Based on [the-nix-way](https://github.com/the-nix-way/dev-templates)

```flake.nix
{
  description = "A Nix-flake-based R development environment";

  inputs.nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1";
  inputs.fran.url = "github:dwinkler1/fran";
  inputs.fran.inputs.nixpkgs.follows = "nixpkgs";

  outputs = inputs: let
    supportedSystems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    forEachSupportedSystem = f:
      inputs.nixpkgs.lib.genAttrs supportedSystems (system:
        f {
          pkgs = import inputs.nixpkgs {
            inherit system;
            overlays = [inputs.fran.overlays.default];
          };
        });
    mkR = inputs.fran.lib.mkR;
  in {
    devShells = forEachSupportedSystem ({pkgs}: {
      default = pkgs.mkShell {
        packages = with pkgs; [
          (mkR {
            inherit pkgs;
            packages = [rPackages.data_table extraRPackages.fwildclusterboot];
          })
        ];
      };
    });
  };
}
```
