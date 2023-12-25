{
  flake-parts-lib,
  self,
  withSystem,
  inputs',
  ...
}: let
  inherit (flake-parts-lib) importApply;
in {
  flake.homeManagerModules.default = importApply ./twixvim.nix {
    localFlake = self;
    inherit inputs';
  };
}
