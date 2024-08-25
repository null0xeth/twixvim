{inputs, ...}: {
  imports = [inputs.devshell.flakeModule];

  perSystem = {
    config,
    system,
    pkgs,
    inputs',
    ...
  }: {
    # packages.default = inputs'.neovim-flake.packages.default;
    # packages.default = self'.packages.twixvim;
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;
      overlays = [
        inputs.rust-overlay.overlays.default
      ];
    };

    devshells.default = {
      devshell = {
        name = "Neovim Devshell";
      };
      env = [];
      packages = inputs.nixpkgs.lib.attrValues {
        inherit (inputs'.nil.packages) default;
        #inherit (config.packages.modified_rust) default;
        inherit (pkgs.luajitPackages) jsregexp luacheck;
        inherit (pkgs.nodePackages) jsonlint;
        #inherit (pkgs.rust-bin.stable.latest) default;
        inherit
          (pkgs)
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
          #yamlfix
          
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
