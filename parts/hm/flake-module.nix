{moduleWithSystem, ...}: {
  flake.homeManagerModules.default = moduleWithSystem (
    perSystem @ {inputs'}: {
      config,
      lib,
      pkgs,
      ...
    }:
      with lib; let
        cfg = config.modules.twixvim;
      in {
        options = {
          modules.twixvim = {
            enable = mkOption {
              type = types.bool;
              default = true;
              description = "Enable Twixvim IDE";
            };
            settings = {
              development = {
                enable = mkOption {
                  type = types.bool;
                  default = false;
                  description = "Work with a local copy of the source";
                };
              };
            };
          };
        };

        config = mkIf cfg.enable (mkMerge [
          {
            home = {
              packages = [
                perSystem.inputs'.neovim-flake.packages.default
                # pkgs.vscode-extensions.vadimcn.vscode-lldb
                # pkgs.vscode
              ];
            };
          }
          (mkIf (!cfg.settings.development.enable) {
            home.file = {
              ".config/nvim" = {
                enable = true;
                source = ../../src;
                recursive = true;
              };
            };
          })
        ]);
      }
  );
}
