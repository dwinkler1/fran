{
  lib,
  prev,
  fetchfromGitHubJSONFile,
  versionsDir,
}: let
  repoSrc = fetchfromGitHubJSONFile "${versionsDir}/jgd.json";

  rPkgSrc = lib.cleanSourceWith {
    src = repoSrc;
    filter = path: type: let
      p = toString path;
    in
      # keep r-pkg/ and everything under it
      (lib.hasPrefix (toString repoSrc + "/r-pkg") p);
  };
in
  prev.rPackages.buildRPackage {
    name = "jgd";
    src = rPkgSrc;
    sourceRoot = "source/r-pkg";
    nativeBuildInputs = [
      prev.pkg-config
    ];
  }
