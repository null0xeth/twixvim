{
  inputs,
  config,
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
        basic = mkEnableOption "only the bare-minimum directory management functions of HM";
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
    (mkIf (!cfg.settings.basic) {
      home = {
        # packages = builtins.attrValues {
        #   inherit (inputs.neovim-flake.packages.x86_64-linux) neovim;
        #   inherit (pkgs.vscode-extensions.vadimcn) vscode-lldb;
        #   inherit (pkgs) vscode;
        # };
        packages = [
          inputs.self.neovim-flake.packages.x86_64-linux.neovim
          pkgs.vscode-extensions.vadimcn.vscode-lldb
          pkgs.vscode
        ];
      };
    })
    (mkIf (!cfg.settings.development.enable && cfg.settings.basic) {
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
