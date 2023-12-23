{
  config,
  inputs,
  pkgs,
  lib,
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
        packages = attrValues {
          inherit (inputs.neovim-flake.packages.x86_64-linux) neovim;
          inherit (pkgs.vscode-extensions.vadimcn) vscode-lldb;
          inherit (pkgs) vscode;
        };
      };
    }
    (mkIf (!cfg.settings.development.enable) {
      xdg.configFile = {
        "nvim" = {
          enable = true;
          source = ../../src;
          recursive = true;
        };
      };
    })
  ]);
}
