import stackage2nix/nix/haskell-packages { nixpkgs = import ((import <nixpkgs> {}).fetchFromGitHub {
  owner = "NixOS";
  repo = "nixpkgs-channels";
  rev = "f607771d0f5e4fa905afff1c772febd9f3103e1a";
  sha256 = "1icphqpdcl8akqhfij2pxkfr7wfn86z5sr3jdjh88p9vv1550dx7";
}) {}; }
