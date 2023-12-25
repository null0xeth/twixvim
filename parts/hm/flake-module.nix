{moduleWithSystem, ...}: {
  flake.homeManagerModules.default = moduleWithSystem (
    perSystem @ {config}: {
      imports = [
        ./twixvim.nix
      ];
    }
  );
}
