{
  prev,
  fetchfromGitHubJSONFile,
  versionsDir,
}:
prev.rPackages.buildRPackage {
  name = "httpgd";
  src = fetchfromGitHubJSONFile "${versionsDir}/httpgd.json";
  propagatedBuildInputs = builtins.attrValues {
    inherit
      (prev.rPackages)
      unigd
      cpp11
      AsioHeaders
      ;
  };
}
