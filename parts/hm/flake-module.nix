{
  moduleWithSystem,
  lib,
  ...
}: {
  flake.homeManagerModules.default = moduleWithSystem (
    perSystem @ {
      config,
      inputs',
      ...
    }:
      with lib; let
        cfg = config.homeManagerModules.twixvim;
      in {
        options = {
          homeManagerModules.twixvim = {
            enable = mkOption {
              type = types.bool;
              default = true;
              description = "Enable Twixvim IDE";
            };
            settings = {
              basic = mkOption {
                type = types.nullOr types.bool;
                description = "only the bare-minimum directory management functions of HM";
                default = null;
              };
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
          #(mkIf (!cfg.settings.basic) {
          {
            assertions = [
              {
                assertion = cfg.settings.basic == null;
                message = "`settings.basic` is deprecated. Please remove it from your config";
              }
            ];
            home = {
              packages = [
                #localFlake.inputs.neovim-flake.packages.x86_64-linux.neovim #does not work...
                inputs'.neovim-flake.packages.default
                pkgs.vscode-extensions.vadimcn.vscode-lldb
                pkgs.vscode
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
