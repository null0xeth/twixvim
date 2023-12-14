{
  config,
  inputs,
  pkgs,
  lib,
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
      dev = mkOption {
        type = types.bool;
        default = false;
        description = "use local src";
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
    (mkIf (cfg.dev == false) {
      xdg.configFile = {
        "nvim" = {
          source = ../../src;
          recursive = true;
        };
      };
    })
  ]);
}
