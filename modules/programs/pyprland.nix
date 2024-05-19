{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.pyprland;
  configPath = "${config.xdg.configHome}/hyprland/pyprland.toml";

  tomlFormat = pkgs.formats.toml { };
in {
  meta.maintainers = [ hm.maintainers.m472 ];

  options = {
    programs.pyprland = {
      enable = mkEnableOption "pyprland";

      package = mkPackageOption pkgs "pyprland" { };

      config = mkOption {
        type = with types;
        let valueType = nullOr (oneOf [
          bool
          int
          float
          str
          path
          (attrsOf valueType)
          (attrsOf valueType)
        ]) // {
          description = "Pyprland configuration value";
        };
        in valueType;

        default = { };
        description = ''
          Pyprland configuration written in Nix.
          See <https://github.com/hyprland-community/pyprland/wiki> for documentation.
        '';
        example = lib.literalExpression ''
          pyprland = {
            plugins = ["scratchpads" "center"];
          };

          scratchpads.term = {
            animation = "fromTop";
            command = "kitty --class kitty-dropterm";
            class = "kitty-dropterm";
            size = "75% 60%";
            max_size = "1920px 100%";
            margin = 50;
          };

          scratchpads.volume = {
            animation = "fromRight";
            command = "pavucontrol";
            class = "pavucontrol";
            size = "40% 90%";
            unfocus = "hide";
            lazy = true;
          };
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    home = mkMerge [
      { packages = [ cfg.package ]; }
      (mkIf (cfg.config != [ ]) {
        file."${configPath}".text = tomlFormat.generate "pyprland-config" cfg.config;
      })
    ];
  };
}
