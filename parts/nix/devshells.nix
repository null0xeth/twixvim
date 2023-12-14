{
  inputs,
  lib,
  ...
}: {
  imports = [
    inputs.devshell.flakeModule
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

    devshells.default = {
      devshell = {
        name = "Neovim Shell";
      };

      packages = lib.attrValues {
        #inherit (config.packages) default;
        inherit (inputs'.nil.packages) nil;
        inherit (pkgs.luajitPackages) jsregexp luacheck;
        inherit (pkgs.nodePackages) jsonlint;
        inherit
          (pkgs)
          clang-tools_16
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
