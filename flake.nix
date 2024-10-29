{
  nixConfig = {
    extra-substituters = ["https://nix-community.cachix.org"];
    extra-trusted-public-keys = [
      nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=
    ];
  };
  description = "Description for the project brrrt";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      #inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix.url = "github:ryantm/agenix";

    agenix-rekey = {
      url = "github:oddlama/agenix-rekey";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    systems = {
      url = "github:nix-systems/default";
      #inputs.nixpkgs.follows = "nixpkgs";
    };

    nil = {
      url = "github:oxalica/nil";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim-flake = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    alejandra = {
      url = "github:kamadorueda/alejandra";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    flake-parts,
    systems,
    rust-overlay,
    nixpkgs,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        #./parts/flake-module.nix
        inputs.agenix-rekey.flakeModule
        inputs.devshell.flakeModule
        ./parts/hm/flake-module.nix
      ];

      systems = import systems;

      perSystem = {
        config,
        system,
        inputs',
        pkgs,
        ...
      }: {
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          config.allowUnfree = true;
          config.hostPlatform = system;
          overlays = [
            inputs.rust-overlay.overlays.default
          ];
        };

        devshells.default = {
          devshell = {
            name = "Neovim Devshell";

            packages = with pkgs;
              [
                luajit_openresty
                luajitPackages.jsregexp
                luajitPackages.luacheck
                python312Packages.pip
                config.agenix-rekey.package

                zulu17
                julia_19-bin
                hadolint
                checkmake
                gitlint
                pgformatter
                tfsec
                hclfmt
                yamlfix
                #php84Packages.composer
                nodePackages.jsonlint
                rust-bin.stable.latest.default
                ripgrep
                nixfmt
                cmake
                ansible-language-server
                ansible-lint
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
                terraform-ls
                tflint
                shfmt
                shellcheck
                bash-language-server

                yamllint
                manix
                gcc
                gnumake
                helm-ls
                typescript
                taplo
                vscode
                docker-compose-language-service
                dockerfile-language-server-nodejs
                gitlab-ci-ls
                ruby-lsp
                rubyPackages.solargraph
                rubocop
                rubyPackages.standard
                rubyPackages.erb-formatter
              ]
              ++ [inputs'.nil.packages.default];
          };
        };
      };
    };
}
