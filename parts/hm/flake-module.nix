{inputs, ...}: {
  flake.homeManagerModules.default = let
    twixvim = import ./twixvim.nix {inherit inputs;};
  in {
    imports = twixvim;
  };
}
