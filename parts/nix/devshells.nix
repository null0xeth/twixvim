{
  inputs,
  lib,
  ...
}: {
  imports = [
    inputs.devenv.flakeModule
  ];

  perSystem = {
    pkgs,
    system,
    config,
    inputs',
    ...
  }: {
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };

    devenv.shells.default = {
      devenv.flakesIntegration = true;

      enterShell = ''
        name="$(pwd)"
      '';

      packages = lib.attrValues {
        #inherit (config.packages) default;
        inherit (inputs'.nil.packages) nil;
        inherit (pkgs.luajitPackages) jsregexp luacheck;
        inherit (pkgs.nodePackages) jsonlint;
        inherit
          (pkgs)
          cmake
          lua-language-server
          marksman
          vscode-langservers-extracted
          yaml-language-server
          alejandra
          nixpkgs-fmt
          statix
          vulnix
          deadnix
          stylua
          prettierd
          yamlfix
          yamllint
          manix
          gcc
          gnumake
          helm-ls
          typescript
          taplo
          vscode
          ;
      };
    };
  };
}
