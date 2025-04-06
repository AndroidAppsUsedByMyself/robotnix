# SPDX-FileCopyrightText: 2020 Daniel Fullmer and robotnix contributors
# SPDX-License-Identifier: MIT
{
  config,
  pkgs,
  apks,
  lib,
  robotnixlib,
  ...
}: let
  inherit (lib) mkIf mkOption mkEnableOption types;

  cfg = config.lindroid;
  vendor_lindroid = {
    LineageOS = {
      "21" = pkgs.fetchFromGitHub {
        owner = "Linux-on-droid";
        repo = "vendor_lindroid";
        rev = "448abc3c437d5101cf42770045fe8796efdf28ed";
        sha256 = "sha256-bmDeDe23VX9M74rfAOuYJWTkkZ5No8o10j5q2XKgGkk=";
      };
      "22.1" = pkgs.fetchFromGitHub {
        owner = "Linux-on-droid";
        repo = "vendor_lindroid";
        rev = "68551065932b320d706f392c246d107ac3154631";
        sha256 = "sha256-69gHIvArfpDhIQ7xRmYWwfZtvPZDfakyE7jhuSR7PwY=";
      };
    };
  };
  external_lxc = pkgs.fetchFromGitHub {
    owner = "Linux-on-droid";
    repo = "external_lxc";
    rev = "4e3a3630fff3dc04e0d4a761309f87f248e40b17";
    sha256 = "sha256-lh/YEh1ubAW51GKFZiraQZqbGGkdT6zuSVunDRAaKbE=";
  };
  libhybris = pkgs.fetchFromGitHub {
    owner = "Linux-on-droid";
    repo = "libhybris";
    rev = "419f3ff6736e01cb0e579f65a34c85cfa7de578b";
    sha256 = "sha256-h9QmJ/uZ2sHMGX3/UcxD+xe/myONacKwoBhmn0RK5sI=";
  };
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
