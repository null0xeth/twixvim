{
  moduleWithSystem,
  ...
}: {
  flake.homeManagerModules.default = moduleWithSystem (
    perSystem @ { config, nixpkgs }: {
      inputs',
      lib,
      pkgs,
      ...
    }:
    #with lib;
      with lib; 
      {
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

        config = 
	  let
	    cfg = config.modules.twixvim;
	 in 
	 mkIf cfg.enable (mkMerge [
          {
            home = {
              packages = [
                inputs'.neovim-flake.packages.default
              ];
            };
          }
          (mkIf (!cfg.settings.development.enable) (mkMerge [
            (mkIf (!cfg.settings.configuration.enable) {
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
            (mkIf cfg.settings.configuration.enable {
              home.file = {
                ".config/nvim" = {
                  enable = true;
                  source = ../../neovim;
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
      });
}
