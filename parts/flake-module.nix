{inputs, ...}: {
  imports = [
    ./nix/devshells.nix
    ./hm/flake-module.nix
  ];

  perSystem = {
    config,
    #pkgs,
    system,
    inputs',
    lib,
    ...
  }: {
    _module.args = {
      pkgs = inputs'.nixpkgs.legacyPackages;
      nixpkgs = {
        config = lib.mkForce {
          allowUnfree = true;
        };

        hostPlatform = system;
        #overlays = [];
      };
    };

    extraModuleArgs = {
      inherit inputs' system;
      inputs = lib.mkForce inputs;
    };

    pre-commit = {
      check.enable = true;
      settings = {
        settings = {
          deadnix = {
            edit = true;
            noLambdaArg = true;
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
