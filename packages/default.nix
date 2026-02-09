{
  final,
  prev,
}: let
  # Shared helper function to fetch from GitHub using JSON version files
  fetchfromGitHubJSONFile = path: prev.fetchFromGitHub (builtins.fromJSON (builtins.readFile path));

  # Reference to the versions directory at the repo root
  versionsDir = ../versions;

  # Common arguments passed to package modules that don't need 'final'
  baseArgs = {
    inherit prev fetchfromGitHubJSONFile versionsDir;
  };

  # Arguments for packages that need access to 'final' (for cross-package dependencies)
  argsWithFinal =
    baseArgs
    // {
      inherit final;
    };
in {
  ## F
  fwildclusterboot = import ./f/fwildclusterboot.nix argsWithFinal;

  ## H
  httpgd = import ./h/httpgd.nix baseArgs;

  ## J
  jgd = import ./j/jgd.nix (baseArgs // {lib = prev.lib;});

  ## M
  musicMetadata = import ./m/musicMetadata.nix baseArgs;

  ## S
  summclust = import ./s/summclust.nix baseArgs;
  synthdid = import ./s/synthdid.nix baseArgs;
}
