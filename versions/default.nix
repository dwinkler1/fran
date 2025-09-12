pkgs: ''
  pg=${pkgs.nix-prefetch-github}/bin/nix-prefetch-github
  $pg --json hannesdatta musicMetadata > versions/musicMetadata.json
  $pg --json nx10 httpgd > versions/httpgd.json
  $pg --json s3alfisc fwildclusterboot > versions/fwildclusterboot.json
  $pg --json synth-inference synthdid > versions/synthdid.json
''
