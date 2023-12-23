{
  config,
  inputs,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.nixosModules.twixvim;
in {
  imports = [./direnv.nix];
  options = {
    nixosModules.twixvim = {
      enable = mkEnableOption "zzz";
      settings = {
        development = {
          enable = mkOption {
            type = types.bool;
            default = false;
            description = "Work with a local copy of the source";
          };
        };
        direnv = {
          enable = mkOption {
            type = types.bool;
            default = cfg.enable;
            description = "Enable the nix-direnv integration";
          };
        };
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      environment = {
        systemPackages = attrValues {
          inherit (inputs.neovim-flake.packages.x86_64-linux) neovim;
          inherit (pkgs.vscode-extensions.vadimcn) vscode-lldb;
          inherit (pkgs) vscode;
        };
      };
    }
    (mkIf cfg.settings.direnv.enable {
      twixModules.direnv = {
        enable = true;
      };
    })
    # (mkIf (!cfg.settings.development.enable) {
    #   xdg.configFile = {
    #     "nvim" = {
    #       enable = true;
    #       source = ../../src;
    #       recursive = true;
    #     };
    #   };
    # })
  ]);
}
