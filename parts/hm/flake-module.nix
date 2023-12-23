{inputs, ...}: {
  flake.homeManagerModules.default = {
    imports = [./twixvim.nix];
  };
}
