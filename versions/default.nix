pkgs: ''
  pg=${pkgs.nix-prefetch-github}/bin/nix-prefetch-github
  $pg --json grantmcdermott jgd > versions/jgd.json
  $pg --json hannesdatta musicMetadata > versions/musicMetadata.json
  $pg --json nx10 httpgd > versions/httpgd.json
  $pg --json s3alfisc fwildclusterboot > versions/fwildclusterboot.json
  $pg --json s3alfisc summclust > versions/summclust.json
  $pg --json synth-inference synthdid > versions/synthdid.json
  RVER=$( wget -qO- 'https://raw.githubusercontent.com/ropensci/rix/refs/heads/main/inst/extdata/available_df.csv' | tail -n 1 | head -n 1 | cut -d',' -f4 | tr -d '"' )
  ${pkgs.gnused}/bin/sed -i "s|nixpkgs.url = \"github:rstats-on-nix/nixpkgs/[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}\";|nixpkgs.url = \"github:rstats-on-nix/nixpkgs/$RVER\";|" flake.nix
''
