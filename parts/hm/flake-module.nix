{
  inputs,
  neovim-flake,
  ...
}: {
  flake.homeManagerModules.default = {
    imports = [./twixvim.nix];
  };
}
