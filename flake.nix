{
  description = "Description for the project brrrt";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    systems.url = "github:nix-systems/default";
    nil.url = "github:oxalica/nil";
    devshell.url = "github:numtide/devshell";
    nix2container.url = "github:nlewo/nix2container";
    nix2container.inputs.nixpkgs.follows = "nixpkgs";
    mk-shell-bin.url = "github:rrbutani/nix-mk-shell-bin";
    neovim-flake.url = "github:neovim/neovim?dir=contrib";
  };

  outputs = inputs @ {
    self,
    flake-parts,
    systems,
    nixpkgs,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        inputs.devshell.flakeModule
        ./parts
      ];
      systems = import systems;

      perSystem = {
        self',
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
        packages.default = self'.packages.twixvim;

        devshells = {
          default = {
            devshell = {name = "Neovim Shell";};

            packages = nixpkgs.lib.attrValues {
              #inherit (config.packages) default;
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
        flake = {
          homeManagerModules.default = import ./parts/hm/twixvim.nix inputs;
        };
    };
}
