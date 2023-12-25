{
  flake-parts-lib,
  self,
  ...
}: let
  inherit (flake-parts-lib) importApply;
in {
  flake.homeManagerModules.default = importApply ./twixvim.nix {
    localFlake = self;
  };
}
