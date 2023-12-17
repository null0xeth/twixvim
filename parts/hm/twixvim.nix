{
  config,
  inputs,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.twixvim;
  devLoc = "etc/nvim_dev";
  devPath = /. + devLoc;
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
            default = true;
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
          inherit (pkgs) vscode lolcat;
        };
      };
      home.file = mkIf cfg.settings.development.enable {
        "nvim_dev".source = ../../src;
      };
    }
    (mkIf cfg.settings.development.enable {
      xdg.configFile = {
        "nvim" = {
          enable = true;
          source = config.lib.file.mkOutOfStoreSymlink devPath;
          recursive = true;
        };
      };
    })
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
