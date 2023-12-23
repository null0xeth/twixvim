{
  inputs,
  neovim-flake,
  ...
}: {
  flake.homeManagerModules.default = {
    inherit inputs;
    imports = [./twixvim.nix];
  };
}
