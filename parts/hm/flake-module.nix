{moduleWithSystem, ...}: {
  flake.homeManagerModules.default = moduleWithSystem (
    perSystem @ {
      nixpkgs,
      inputs,
    }: {
      config,
      lib,
      pkgs,
      ...
    }:
    #with lib;
      with lib; {
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

        config = mkIf config.modules.twixvim.enable (mkMerge [
          {
            nixpkgs.overlays = [inputs.neovim-flake.overlays.default];
            home = {
              packages = [
                pkgs.neovim
                #inputs'.neovim-flake.packages.default
              ];
            };
          }
          (mkIf (!config.modules.twixvim.settings.development.enable) (mkMerge [
            (mkIf (!config.modules.twixvim.settings.configuration.enable) {
              home.file = {
                ".config/nvim" = {
                  enable = true;
                  source = ../../neovim;
                  recursive = true;
                };
                ".config/nvim/lua/config.lua" = {
                  enable = true;
                  source = ../../config.lua;
                };
              };
            })
            (mkIf config.modules.twixvim.settings.configuration.enable {
              home.file = {
                ".config/nvim" = {
                  enable = true;
                  source = ../../neovim;
                  recursive = true;
                };
                ".config/nvim/lua/config.lua" = {
                  enable = true;
                  source = config.modules.twixvim.settings.configuration.path;
                };
              };
            })
          ]))
        ]);
      }
  );
}
