{config, lib, ...}:
  with lib;
      let
    cfg = config.modules.development;
    isEnabled = (modules.twixvim.enable && modules.twixvim.settings.development.enable);
    devLoc = "nvim_dev";
  in {
    options.modules.development = {
     enable = mkOption {
        type = types.bool;
        default = isEnabled;
        description = "Enable the development module";
      };
    };
    config = mkIf cfg.enable {
      environment.etc = {
        "${devLoc}".source = ../../src;
      };
    };
  }
