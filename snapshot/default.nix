f:

let
  nixpkgs-boot = import ./nixpkgs.nix {};
  boot-lib = nixpkgs-boot.lib;

  options = { options, config, lib, ... }: with lib; with types; {
    options.nixpkgs = mkOption {
      description = "nixpkgs";
      type = attrsOf (submodule (_: { options = {
        src = mkOption {
          description = "src";
          type = path;
          default = ./nixpkgs.nix;
        };
        args = mkOption {
          description = "args";
          type = unspecified;
          default = {};
        };
        compilers = mkOption {
          description = "compilers";
          type = attrsOf (submodule (_: {
            options.ghc = mkOption {
              description = "ghc";
              type = either package str;
              default = "ghc802";
            };
            options.targets = mkOption {
              description = "targets";
              default = _: [];
              type = unspecified;
            };
          }));
        };
      };}));
    };

    options.name = mkOption {
      description = "name";
      default = "haskell-project";
      type = str;
    };

    options.overrides = mkOption {
      description = "overrides";
      type = mkOptionType {
        name = "overrides";
        description = "Haskell overrides, in the form of `{ pkgs, haskellLib, ... }: self: super: { ... }`";
        merge = locs: defs: lib.foldr (f: g: args: lib.composeExtensions (f.value args) (g args)) (_: _: _: {}) defs;
      };
    };

    options.project = mkOption {
      description = "project";
      type = unspecified;
    };

    options.haskell-modules-dir = mkOption {
      description = "haskell-modules-dir";
      type = unspecified;
      default = pkgs: pkgs.path + /pkgs/development/haskell-modules;
    };

    options.checkPackageSet = mkOption {
      description = "checkPackageSet";
      type = bool;
      default = false;
    };

    options.packages = mkOption {
      description = "packages";
      type = attrsOf (either str (either path package));
      default = {};
    };

    config.overrides = { haskellLib, pkgs, ... }: self: _: {
      shellFor = { packages, withHoogle ? false }:
        let
          selected = packages self;
          packageInputs = builtins.map (p: p.override { mkDerivation = haskellLib.extractBuildInputs p.compiler; }) selected;
          haskellInputs =
            builtins.filter
              (input: pkgs.lib.all (p: builtins.toString input != builtins.toString p) selected)
              (pkgs.lib.concatMap (p: p.haskellBuildInputs) packageInputs);
          systemInputs = pkgs.lib.concatMap (p: p.systemBuildInputs) packageInputs;
          withPackages = if withHoogle then self.ghcWithHoogle else self.ghcWithPackages;
        in pkgs.stdenv.mkDerivation {
          name = "ghc-shell-for-packages";
          nativeBuildInputs =
            [(withPackages (_: haskellInputs))]
            ++ systemInputs;
          phases = ["installPhase"];
          installPhase = "echo $nativeBuildInputs > $out";
        };
    };

    config.nixpkgs.mypkgs.compilers.myghc = {};

    config.project = boot-lib.mapAttrs (_: { src, args, compilers, ... }:
      let haskellLib = nixpkgs.callPackage (config.haskell-modules-dir nixpkgs + /lib.nix) {};
          nixpkgs = import src args;
      in boot-lib.mapAttrs (_: { ghc, targets, ... }:
        let
          makeSet = pkgs: ghc:
            let self = pkgs.callPackage (config.haskell-modules-dir pkgs) {
              inherit ghc haskellLib;
              buildHaskellPackages =
                if pkgs.stdenv.hostPlatform != pkgs.stdenv.buildPlatform || ghc.isGhcjs or false
                  then makeSet pkgs.buildPackages ghc.bootPkgs.ghc
                  else self;
              initialPackages = import ./packages.nix;
              compilerConfig = import ./configuration-packages.nix { inherit pkgs haskellLib; };
              configurationCommon = args:
                pkgs.lib.composeExtensions
                  (haskellLib.packageSourceOverrides config.packages)
                  (config.overrides args);
              packageSetConfig = self: super: boot-lib.optionalAttrs (!config.checkPackageSet) {
                mkDerivation = args: super.mkDerivation ({ doCheck = false; } // args);
              };
            };
            in self // { devShell = self.shellFor { packages = targets; }; };
          ghcDrv =
            if builtins.typeOf ghc == "string"
              then nixpkgs.buildPackages.haskell.compiler.${ghc}
              else ghc;
        in makeSet nixpkgs ghcDrv)
      compilers // { pkgs = nixpkgs; }) config.nixpkgs;

    config._module.args = { inherit nixpkgs-boot; inherit (config) project; };
  };

  conf = nixpkgs-boot.lib.evalModules { modules = [f options]; };

  
in nixpkgs-boot.stdenv.mkDerivation {
  inherit (conf.config) name;
  phases = ["installPhase"];
  passthru = conf.config.project;

  installPhase =
    let inherit (boot-lib) optionalString concatStringsSep
          mapAttrsToList concatMapStringsSep;
        unlinesMapAttrs = attrs: f: concatStringsSep "\n" (mapAttrsToList f attrs);
    in ''
      mkdir -p $out
      ${optionalString (conf.config.nixpkgs != {}) (unlinesMapAttrs conf.config.nixpkgs (pkgsname: { compilers, ... }:
        optionalString (compilers != {})
          (unlinesMapAttrs compilers (compilername: { targets, ... }: let
            selected = targets conf.config.project.${pkgsname}.${compilername};
          in optionalString (selected != []) ''
            mkdir -p $out/${pkgsname}/${compilername}
            ${concatMapStringsSep "\n" (p: ''
              ln -s ${p} $out/${pkgsname}/${compilername}/${p.pname}
            '') selected}
          ''))
      ))}
    '';
}
