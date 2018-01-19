import ../../snapshot ({ nixpkgs-boot, lib, ... }: let
  systems = import (nixpkgs-boot.path + /lib/systems/examples.nix) { inherit lib; };
in {
  nixpkgs.armpkgs = {
    args.crossSystem = systems.raspberryPi;
    compilers.armghc = {
      ghc = "ghc822";
      targets = p: with p; [hello];
    };
  };
  nixpkgs.aarch64pkgs = {
    args.crossSystem = systems.aarch64-multiplatform;
    compilers.aarch64ghc = {
      ghc = "ghc822";
      targets = p: with p; [hello];
    };
  };

  packages = {
    hello = "1.0.0.2";
  };
})
