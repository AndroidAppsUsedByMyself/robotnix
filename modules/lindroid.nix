# SPDX-FileCopyrightText: 2020 Daniel Fullmer and robotnix contributors
# SPDX-License-Identifier: MIT
{
  config,
  lib,
  sources,
  ...
}: let
  inherit (lib) mkIf mkOption mkEnableOption types;

  cfg = config.lindroid;
  vendor_lindroid = {
    LineageOS = {
      "21" = sources."vendor_lindroid_21".src;
      "22.1" = sources."vendor_lindroid_22_1".src;
    };
  };
  external_lxc = sources."external_lxc".src;
  libhybris = sources."libhybris".src;
in {
  options.lindroid = {
    enable = mkEnableOption "Lindroid Support";
    systemVersion = mkOption {
      type = types.str;
      default = "LineageOS_22.1";
      description = ''
        The system version of LineageOS to use. This is used to determine the
        correct vendor_lindroid repository to use.
      '';
    };
  };

  config = mkIf cfg.enable {
    source.dirs = {
      "vendor/lindroid" = {
        src =
          if cfg.systemVersion == "LineageOS_22.1"
          then vendor_lindroid.LineageOS."22.1"
          else if cfg.systemVersion == "LineageOS_21"
          then vendor_lindroid.LineageOS."21"
          else
            (
              lib.warn "Lindroid: Unknown system version ${cfg.systemVersion}, defaulting to LineageOS_21"
              vendor_lindroid.LineageOS."21"
            );
        patches = [
        ];
      };
      "external/lxc" = {
        src = external_lxc;
        patches = [
        ];
      };
      "libhybris" = {
        src = libhybris;
        patches = [
        ];
      };
    };
    # IDK if iy work
    # https://github.com/nix-community/robotnix/blob/9143e19766de7dd3bbf01e2cb5b2718c6208c37f/modules/base.nix#L170-L189
    vendor.extraConfig = "$(call inherit-product, vendor/lindroid/lindroid.mk)";
  };
}
