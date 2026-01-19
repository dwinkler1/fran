{
  prev,
  fetchfromGitHubJSONFile,
  versionsDir,
}:
prev.rPackages.buildRPackage {
  name = "synthdid";
  src = fetchfromGitHubJSONFile "${versionsDir}/synthdid.json";
  propagatedBuildInputs = [prev.rPackages.mvtnorm];
}
