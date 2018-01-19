import ./snapshot ({ nixpkgs-boot, project, lib, config, ... }: let
  systems = import (nixpkgs-boot.path + /lib/systems/examples.nix) { inherit lib; };
in {
  nixpkgs.mypkgs.compilers = {
    myghc.packages = p: with p; [reflex-todomvc];
    myghcjs.packages = p: with p; [reflex-todomvc];
  };

  nixpkgs.armpkgs = {
    args.crossSystem = systems.raspberryPi;
    compilers.armghc = {
      ghc = "ghc822";
      packages = p: with p; [hello];
    };
  };
  nixpkgs.aarch64pkgs = {
    args.crossSystem = systems.aarch64-multiplatform;
    compilers.aarch64ghc = {
      ghc = "ghc822";
      packages = p: with p; [hello];
    };
  };

  packages = {
    hello = "1.0.0.2";
    kleisli-functors = nixpkgs-boot.fetchFromGitHub {
      owner = "ElvishJerricco";
      repo = "kleisli-functors";
      rev = "d0bde122c1d0c988b16d3737bba712931b25c963";
      sha256 = "0r95s64m30zbg6nbkcb6bdld1s39ygnvklf162frrd6m1ra0bl4c";
    };
  };

  imports = [./reflex.nix];
  nixpkgs.mypkgs.args.config.permittedInsecurePackages = [
    "webkitgtk-2.4.11"
  ];
})
