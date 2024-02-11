{
  moduleWithSystem,
  inputs,
  ...
}: {
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
              configuration = {
                enable = mkEnableOption "the ability to override default config";
                path = mkOption {
                  type = types.path;
                  description = "Path to config.lua";
                  default = ../../config.lua;
                };
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
          {
            programs.nix-ld.enable = lib.mkDefault false;
            home = {
              packages = [
                pkgs.neovim
                #inputs.neovim-flake.packages.x86_64-linux.neovim
                # pkgs.vscode-extensions.vadimcn.vscode-lldb
                # pkgs.vscode
              ];
            };
          }
          (mkIf (!cfg.settings.development.enable) (mkMerge [
            (mkIf (!cfg.settings.configuration.enable) {
              home.file = {
                ".config/nvim" = {
                  enable = true;
                  source = ../../src;
                  recursive = true;
                };
                ".config/nvim/lua/config.lua" = {
                  enable = true;
                  source = ../../config.lua;
                };
              };
            })
            (mkIf cfg.settings.configuration.enable {
              home.file = {
                ".config/nvim" = {
                  enable = true;
                  source = ../../src;
                  recursive = true;
                };
                ".config/nvim/lua/config.lua" = {
                  enable = true;
                  source = cfg.settings.configuration.path;
                };
              };
            })
          ]))
        ]);
      }
  );
}
