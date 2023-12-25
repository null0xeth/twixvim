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
    };

    # _module.args = {
    #   pkgs = inputs'.nixpkgs.legacyPackages;
    #   nixpkgs = {
    #     config = lib.mkForce {
    #       allowUnfree = true;
    #     };

    #     hostPlatform = system;
    #     #overlays = [];
    #   };
    # };

    pre-commit = {
      check.enable = true;
      settings = {
        settings = {
          deadnix = {
            edit = true;
            noLambdaArg = true;
            noLambdaPatternNames = true;
          };
        };
        hooks = {
          statix = {
            enable = true;
          };
          deadnix = {
            enable = true;
          };
        };
      };
    };

    formatter = inputs'.alejandra.packages.default;
  };
}
