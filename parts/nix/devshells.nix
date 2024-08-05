{inputs, ...}: {
  imports = [inputs.devshell.flakeModule];

  perSystem = {
    pkgs,
    inputs',
    ...
  }: {
    # packages.default = inputs'.neovim-flake.packages.default;
    # packages.default = self'.packages.twixvim;

    devshells.default = {
      env = [];
      packages = inputs.nixpkgs.lib.attrValues {
        inherit (inputs'.nil.packages) default;
        inherit (pkgs.luajitPackages) jsregexp luacheck;
        inherit (pkgs.nodePackages) jsonlint;
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
