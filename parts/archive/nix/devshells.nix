{
  inputs,
  lib,
  ...
}: {
  imports = [inputs.devshell.flakeModule];

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

    packages.twixvim = inputs'.neovim-flake.packages.default;

    devshells = {
      default = {
        devshell = {name = "Neovim Shell";};

        packages = lib.attrValues {
          inherit (inputs'.nil.packages) nil;
          inherit (pkgs.luajitPackages) jsregexp luacheck;
          inherit (pkgs.nodePackages) jsonlint;
          inherit
            (pkgs)
            #clang-tools_16

            nixfmt
            cmake
            lua-language-server
            marksman
            vscode-langservers-extracted
            actionlint
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
  };
}
