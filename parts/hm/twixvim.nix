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
          };
  };

  config = mkIf cfg.enable {
      home = {
        packages = attrValues {
          inherit (inputs.neovim-flake.packages.x86_64-linux) neovim;
          inherit (pkgs.vscode-extensions.vadimcn) vscode-lldb;
          inherit (pkgs) vscode lolcat;
        };
	      };
      #xdg.configFile = {
        home.file.".config/nvim" = {
          enable = true;
	  source = ../../src;
          recursive = true;
        };
      };
    };
}
