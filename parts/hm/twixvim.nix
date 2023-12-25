# #{localFlake}:
# #inputs: {
# {
#   config,
#   inputs',
#   pkgs,
#   lib,
#   ...
# }:
{moduleWithSystem, ...}: {
  flake.homeManagerModules.default = moduleWithSystem (
    perSystem @ {inputs'}: nixos @ {
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
          #(mkIf (!cfg.settings.basic) {
          {
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
