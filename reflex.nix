{ project, config, nixpkgs-boot, lib, ... }: let
  inherit (nixpkgs-boot) fetchFromGitHub;
in {
  nixpkgs.mypkgs.compilers = {
    myghc = {};
    myghcjs = {
      ghc = project.mypkgs.pkgs.haskell.compiler.ghcjsHEAD.override (drv: {
        bootPkgs = project.mypkgs.myghc;
      });
    };
  };

  packages = let
    reflex-dom-src = fetchFromGitHub {
      owner = "reflex-frp";
      repo = "reflex-dom";
      rev = "748e7c1732c90a49a0cdf3b2d85b7aab2dcfd01f";
      sha256 = "09y0xnax42q0mv56xh1sv0z23gnycy8ym9w94nwap6nhhqwk0cd6";
    };
  in {
    bzlib = "0.5.0.5";
    jsaddle-webkit2gtk = "0.9.4.0";
    jsaddle-clib = "0.9.0.0";
    ref-tf = "0.4.0.1";
    prim-uniq = "0.1.0.1";
    dependent-sum-template = "0.0.0.6";
    ghcjs-dom = "0.9.2.0";
    jsaddle = "0.9.4.0";
    zenc = "0.1.1";
    ghcjs-dom-jsaddle = "0.9.2.0";
    jsaddle-dom = "0.9.2.0";
    gi-webkit2 = "4.0.14";
    ghcjs-dom-jsffi = "0.9.2.0";
    haskell-gi-overloading = "0.0";
    webkit2gtk3-javascriptcore = "0.14.2.1";
    gi-javascriptcore = "4.0.14";
    cabal-macosx = "0.2.4.1";
    jsaddle-wkwebview = "0.9.4.0";
    jsaddle-warp = "0.9.5.0";
    ghcjs-base = fetchFromGitHub {
      owner = "ghcjs";
      repo = "ghcjs-base";
      rev = "43804668a887903d27caada85693b16673283c57";
      sha256 = "1pqmgkan6xhpvsb64rh2zaxymxk4jg9c3hdxdb2cnn6jpx7jsl44";
    };

    reflex = fetchFromGitHub {
      owner = "reflex-frp";
      repo = "reflex";
      rev = "e8029ed9db6c29b784f5ca1b8896642379680cb5";
      sha256 = "143p2yy8szd5mn3vwhk54b2y33bcsh595rks8lm33r8v1gkbhnm8";
    };
    reflex-dom-core = "${reflex-dom-src}/reflex-dom-core";
    reflex-dom = "${reflex-dom-src}/reflex-dom";
  };

  overrides = { haskellLib, ... }: self: super: let
    inherit (haskellLib) doJailbreak dontHaddock;
  in {
    # reflex = self.callPackage (fetchFromGitHub {
    #   owner = "reflex-frp";
    #   repo = "reflex";
    #   rev = "e8029ed9db6c29b784f5ca1b8896642379680cb5";
    #   sha256 = "143p2yy8szd5mn3vwhk54b2y33bcsh595rks8lm33r8v1gkbhnm8";
    # }) {};
    # reflex-dom = self.callPackage "${reflex-dom-src}/reflex-dom" {};
    # reflex-dom-core = self.callPackage "${reflex-dom-src}/reflex-dom-core" {};
    reflex-todomvc = self.callPackage (fetchFromGitHub {
      owner = "reflex-frp";
      repo = "reflex-todomvc";
      rev = "cd15a37b0e6decf42840967ce5fba6a03cf278fa";
      sha256 = "0ica2zsx2g1snnfphw4kpsl2b8g09a8v9d43s4xdb2y7ymfncbgv";
    }) {};

    ghcjs-prim = null;
    ghcjs-base = doJailbreak super.ghcjs-base;
    primitive = if self.ghc.isGhcjs or false then null else super.primitive;
    ghcjs-dom = dontHaddock super.ghcjs-dom;
    haskell-gi-overloading = dontHaddock super.haskell-gi-overloading;
    ghcjs-dom-jsaddle = dontHaddock super.ghcjs-dom-jsaddle;
  };
}
