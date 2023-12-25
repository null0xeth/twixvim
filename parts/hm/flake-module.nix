{
  moduleWithSystem,
  inputs,
  ...
}: {
  flake.homeManagerModules.default = moduleWithSystem (
    perSystem @ {
      config,
      inputs',
    }: {...}: {
      imports = [
        ./twixvim.nix
      ];
    }
  );
}
