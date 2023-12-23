{
  flake.nixosModules.default = {
    imports = [./nixosModules.nix];
  };
}
