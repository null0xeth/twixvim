{inputs, ...}: {
  imports = [
    inputs.devshell.flakeModule
    ./hm/flake-module.nix
  ];

  perSystem = {
    config,
    pkgs,
    system,
    inputs',
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
      };
      env = [];
      packages = with pkgs;
        [
          luajit_openresty
          luajitPackages.jsregexp
          luajitPackages.luacheck
          python312Packages.pip
          ruby
          #php84
          #nodejs_22
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
        ]
        ++ [inputs'.nil.packages.default];
    };
  };
}
