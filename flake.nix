{
  description = "FRAN - The Flakey R Archiving Network";

  inputs = {
    nixpkgs.url = "github:rstats-on-nix/nixpkgs/2025-11-10";
  };

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: let
    systems = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
    forAllSystems = nixpkgs.lib.genAttrs systems;

    mkR = {
      pkgs,
      packages,
    }: let
      juliaPackages = builtins.concatMap (p: (p.passthru or {}).juliaPackages or []) packages;
    in
      pkgs.buildEnv {
        name = "rWithDependencies";
        paths =
          [
            (pkgs.rWrapper.override {inherit packages;})
          ]
          ++ (pkgs.lib.optionals (builtins.length juliaPackages > 0) [
            (pkgs.julia-bin.withPackages juliaPackages)
          ]);
      };

    # The overlay that exposes custom R packages
    overlay = final: prev: {
      extraRPackageDeps = {
        julia-fwildclusterboot = prev.julia-bin.withPackages ["WildBootTests" "StableRNGs"];
      };
      extraRPackages = import ./packages {inherit final prev;};
    };
  in {
    # Helper to install R with system dependencies if required
    lib = {inherit mkR;};

    # For imports in other flakes
    overlays.default = overlay;

    # run these with `nix run .#NAME`
    packages = forAllSystems (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [self.overlays.default];
        };
      in {
        default = mkR {
          inherit pkgs;
          packages = builtins.attrValues pkgs.extraRPackages;
        };
        franUpdate = pkgs.writeShellScriptBin "fran-update" (import ./versions pkgs);
      }
    );
    # Run this with `nix develop`
    devShells = forAllSystems (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [self.overlays.default];
        };
      in {
        default = pkgs.mkShell {
          packages = with self.packages."${system}"; [
            default
            franUpdate
          ];
        };
      }
    );
  };
  nixConfig = {
    extra-substituters = [
      "https://rstats-on-nix.cachix.org"
      "https://rde.cachix.org"
    ];
    extra-trusted-public-keys = [
      "rstats-on-nix.cachix.org-1:vdiiVgocg6WeJrODIqdprZRUrhi1JzhBnXv7aWI6+F0="
      "rde.cachix.org-1:yRxQYM+69N/dVER6HNWRjsjytZnJVXLS/+t/LI9d1D4="
    ];
  };
}
