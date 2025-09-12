{
  description = "FRAN - The Flakey R Archiving Network";

  inputs = {
    nixpkgs.url = "github:rstats-on-nix/nixpkgs/r-daily";
    nvimcom = {
      url = "github:R-nvim/R.nvim";
      flake = false;
    };
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

    # The overlay that exposes custom R packages
    overlay = final: prev: {
      extraRPackages = let
        fetchfromGitHubJSONFile = path: prev.fetchFromGitHub (builtins.fromJSON (builtins.readFile path));
      in {
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
        nvimcom = prev.rPackages.buildRPackage {
          name = "nvimcom";
          src = inputs.nvimcom;
          sourceRoot = "source/nvimcom";
          buildInputs = with prev; [
            R
            stdenv.cc.cc
            gnumake
          ];
        };

        ## S
        synthdid = prev.rPackages.buildRPackage {
          name = "synthdid";
          src = fetchfromGitHubJSONFile ./versions/synthdid.json;
          propagatedBuildInputs = [prev.rPackages.mvtnorm];
        };
      };
    };
  in {
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
        default = pkgs.rWrapper.override {packages = builtins.attrValues pkgs.extraRPackages;};
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
