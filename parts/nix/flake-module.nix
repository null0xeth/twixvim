_: {
  flake.nixosModules.default = {
    imports = [./nixosModules.nix];
  };
}
