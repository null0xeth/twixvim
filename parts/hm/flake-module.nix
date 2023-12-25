{
  flake-parts-lib,
  self,
  withSystem,
  ...
}: let
  inherit (flake-parts-lib) importApply;
in {
  flake.homeManagerModules.default = importApply ./twixvim.nix {
    localFlake = self;
    inherit withSystem;
  };
}
