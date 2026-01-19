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
      extraRPackages = let
        fetchfromGitHubJSONFile = path: prev.fetchFromGitHub (builtins.fromJSON (builtins.readFile path));
      in {
        ## F
        fwildclusterboot =
          (prev.rPackages.buildRPackage {
            name = "fwildclusterboot";
            src = fetchfromGitHubJSONFile ./versions/fwildclusterboot.json;
            propagatedBuildInputs = builtins.attrValues {
              inherit
                (prev.rPackages)
                collapse
                dqrng
                dreamerr
                Formula
                generics
                gtools
                JuliaConnectoR
                Matrix
                Rcpp
                rlang
                RcppArmadillo
                RcppEigen
               ;
              inherit (final.extraRPackages) summclust;
            };
          }).overrideAttrs (old: {
            passthru = (old.passthru or {}) // {juliaPackages = ["WildBootTests" "StableRNGs"];};
          });

        ## H
        httpgd = prev.rPackages.buildRPackage {
          name = "httpgd";
          src = fetchfromGitHubJSONFile ./versions/httpgd.json;
          propagatedBuildInputs = builtins.attrValues {
            inherit
              (prev.rPackages)
              unigd
              cpp11
              AsioHeaders
              ;
          };
        };

        ## M
        musicMetadata = prev.rPackages.buildRPackage {
          name = "musicMetadata";
          src = fetchfromGitHubJSONFile ./versions/musicMetadata.json;
        };

        ## N

        ## S
        summclust = prev.rPackages.buildRPackage {
          name = "summclust";

          src = fetchfromGitHubJSONFile ./versions/summclust.json;

          propagatedBuildInputs = builtins.attrValues {
            inherit
              (prev.rPackages)
            dreamerr
            MASS
            collapse
            generics
            cli
            rlang
            ;
          };
        };

        synthdid = prev.rPackages.buildRPackage {
          name = "synthdid";
          src = fetchfromGitHubJSONFile ./versions/synthdid.json;
          propagatedBuildInputs = [prev.rPackages.mvtnorm];
        };
      };
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
        newPkg = pkgs.mkShell {
          packages = with self.packages."${system}"; [
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
