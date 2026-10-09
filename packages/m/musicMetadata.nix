{
  prev,
  fetchfromGitHubJSONFile,
  versionsDir,
}:
prev.rPackages.buildRPackage {
  pname = "musicMetadata";
  name = "musicMetadata";
  src = fetchfromGitHubJSONFile "${versionsDir}/musicMetadata.json";
}
