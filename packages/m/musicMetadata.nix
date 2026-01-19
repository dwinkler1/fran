{
  final,
  prev,
  fetchfromGitHubJSONFile,
  versionsDir,
}:
prev.rPackages.buildRPackage {
  name = "musicMetadata";
  src = fetchfromGitHubJSONFile "${versionsDir}/musicMetadata.json";
}
