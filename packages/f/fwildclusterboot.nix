{
  final,
  prev,
  fetchfromGitHubJSONFile,
  versionsDir,
}:
(prev.rPackages.buildRPackage {
  name = "fwildclusterboot";
  src = fetchfromGitHubJSONFile "${versionsDir}/fwildclusterboot.json";
  propagatedBuildInputs = builtins.attrValues {
    inherit
      (prev.rPackages)
      collapse
      dqrng
      dreamerr
      Formula
      generics
      gtools
      JuliaConnectoR
      Matrix
      Rcpp
      rlang
      RcppArmadillo
      RcppEigen
      ;
    inherit (final.extraRPackages) summclust;
  };
}).overrideAttrs (old: {
  passthru = (old.passthru or {}) // {juliaPackages = ["WildBootTests" "StableRNGs"];};
})
