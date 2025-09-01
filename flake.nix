{
  description = "FRAN - The Flakey R Archiving Network";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
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
    in {
      extraRPackages = {
        musicMetadata = prev.rPackages.buildRPackage {
          name = "musicMetadata";
          src = prev.fetchgit {
            url = "https://github.com/hannesdatta/musicMetadata";
            branchName = "master";
            rev = "1b7ca4c1fd208475e961b77edc90ad513b936879";
            sha256 = "sha256-QK1Q6/ta2PqIrjdA6/oS1HxOMgZr/BO00OLjs3/O7EE=";
          };
        };
        synthdid = prev.rPackages.buildRPackage {
          name = "synthdid";
          src = prev.fetchFromGitHub {
            owner = "synth-inference";
            repo = "synthdid";
            rev = "70c1ce3eac58e28c30b67435ca377bb48baa9b8a";
            sha256 = "sha256-rxQqnpKWy4d9ZykRxfILu1lyT6Z3x++gFdC3sbm++pk=";
          };
          propagatedBuildInputs = [prev.rPackages.mvtnorm];
        };
        httpgd = prev.rPackages.buildRPackage {
          name = "httpgd";
          src = prev.fetchgit {
            url = "https://github.com/nx10/httpgd";
            rev = "dd6ed3a687a2d7327bb28ca46725a0a203eb2a19";
            sha256 = "sha256-vs6MTdVJXhTdzPXKqQR+qu1KbhF+vfyzZXIrFsuKMtU=";
          };
          propagatedBuildInputs = builtins.attrValues {
            inherit
              (prev.rPackages)
              unigd
              cpp11
              AsioHeaders
              ;
          };
        };
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

        # Template for adding more packages:
        # somepkg = mkGitR {
        #   pname = "somepkg";
        #   src = somepkg;          # from inputs (add it above)
        #   subdir = ".";           # change if the R pkg is in a subfolder
        #   propagatedBuildInputs = with final.rPackages; [ <deps> ];
        #   buildInputs = [ <system-libs-if-needed> ];
        # };
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
        default = pkgs.rWrapper.override {packages = builtins.attrNames pkgs.extraRPackages;};
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
        packages = [
          (pkgs.rWrapper.override {
            packages = with pkgs.extraRPackages; [
              nvimcom
              musicMetadata
              synthdid
              httpgd
            ];
          })
        ];
      };
    });
  };
}
