{
  final,
  prev,
  fetchfromGitHubJSONFile,
  versionsDir,
}:
prev.rPackages.buildRPackage {
  name = "summclust";
  src = fetchfromGitHubJSONFile "${versionsDir}/summclust.json";
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
}
