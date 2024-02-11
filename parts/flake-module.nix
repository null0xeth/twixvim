{inputs, ...}: {
  imports = [
    inputs.pre-commit-hooks-nix.flakeModule
    ./nix/devshells.nix
    ./hm/flake-module.nix
  ];

  perSystem = {
    config,
    pkgs,
    system,
    inputs',
    lib,
    ...
  }: {
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;
      config.allowUnfree = true;
      config.hostPlatform = system;
      overlays = [
        inputs.neovim-flake.overlays.default
      ];
    };
  };
}
