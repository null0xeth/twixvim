{inputs, ...}: {
  flake.homeManagerModules.default = let
    twixvim = import ./twixvim.nix {};
  in {
    imports = twixvim;
  };
}
