{
  prev,
  fetchfromGitHubJSONFile,
  versionsDir,
}:
prev.rPackages.buildRPackage {
  pname = "synthdid";
  name = "synthdid";
  src = fetchfromGitHubJSONFile "${versionsDir}/synthdid.json";
  propagatedBuildInputs = [prev.rPackages.mvtnorm];
}
