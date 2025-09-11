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
    forAllSystems = f:
      builtins.listToAttrs (map (system: {
          name = system;
          value = f system;
        })
        systems);

    # The overlay that exposes custom R packages
    overlay = final: prev: let
      readJSONFile = path: builtins.fromJSON (builtins.readFile path);
    in {
      extraRPackages = {
        ## H
        httpgd = let
          httpgdLatest = readJSONFile ./versions/httpgd.json;
        in
          prev.rPackages.buildRPackage {
            name = "httpgd";
            src = prev.fetchFromGitHub httpgdLatest;
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
        musicMetadata = let
          musicMetadataLatest = readJSONFile ./versions/musicMetadata.json;
        in
          prev.rPackages.buildRPackage {
            name = "musicMetadata";
            src = prev.fetchFromGitHub musicMetadataLatest;
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
        synthdid = let
          synthdidLatest = readJSONFile ./versions/synthdid.json;
        in
          prev.rPackages.buildRPackage {
            name = "synthdid";
            src = prev.fetchFromGitHub synthdidLatest;
            propagatedBuildInputs = [prev.rPackages.mvtnorm];
          };
      };
    };
  in {
    overlays.default = overlay;

    # Optional: provide an R wrapper with these non-CRAN packages bundled
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
    # Helpful for overlay users: expose a devShell with R including these pkgs
    devShells = forAllSystems (system: let
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
    });
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
