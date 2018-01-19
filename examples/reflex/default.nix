import ../../snapshot ({ ... }: {
  nixpkgs.mypkgs.compilers = {
    myghc.packages = p: with p; [backend common frontend];
    myghcjs.packages = p: with p; [common frontend];
  };

  packages = {
    backend = ./backend;
    common = ./common;
    frontend = ./frontend;
  };
  
  imports = [../../reflex-module.nix];
  nixpkgs.mypkgs.args.config.permittedInsecurePackages = [
    "webkitgtk-2.4.11"
  ];
})
