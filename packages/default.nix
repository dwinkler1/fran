{
  final,
  prev,
}:
let
  # Shared helper function to fetch from GitHub using JSON version files
  fetchfromGitHubJSONFile = path: prev.fetchFromGitHub (builtins.fromJSON (builtins.readFile path));
  
  # Reference to the versions directory at the repo root
  versionsDir = ../versions;
  
  # Common arguments passed to all package modules
  commonArgs = {
    inherit final prev fetchfromGitHubJSONFile versionsDir;
  };
in {
  ## F
  fwildclusterboot = import ./f/fwildclusterboot.nix commonArgs;
  
  ## H
  httpgd = import ./h/httpgd.nix commonArgs;
  
  ## M
  musicMetadata = import ./m/musicMetadata.nix commonArgs;
  
  ## S
  summclust = import ./s/summclust.nix commonArgs;
  synthdid = import ./s/synthdid.nix commonArgs;
}
