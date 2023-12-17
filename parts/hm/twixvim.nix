{
  config,
  inputs,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.twixvim;
  devLoc = "etc/";
  devFolder = "nvim_dev";
  devPath = /. + devLoc + devFolder;
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
      environment.etc = mkIf cfg.settings.development.enable {
        "${devFolder}".source = ../../src;
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
      "nvim" = {
        xdg.configFile = {
          enable = true;
          source = ../../src;
          recursive = true;
        };
      };
    })
  ]);
}
