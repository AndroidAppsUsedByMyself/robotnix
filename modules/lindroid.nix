# SPDX-FileCopyrightText: 2024 Mayuri, Daniel Fullmer and robotnix contributors
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

  # 函数：从字符串提取系统发行版和版本号
  extractSystemInfo = str:
    let
      # 匹配发行版和版本号
      match = builtins.match "([A-Za-z_]+)?[_-]?([0-9.]+)?" str;
      distro = if match != null then builtins.elemAt match 0 else null;
      version = if match != null then builtins.elemAt match 1 else null;
      
      # 规范化发行版名称
      normalizedDistro =
        if distro == null then null
        else if builtins.match ".*[Ll]ineage.*" distro != null then "LineageOS"
        else distro;
      
      # 规范化版本号
      normalizedVersion =
        if version == null then null
        else if builtins.match "21.*" version != null then "21"
        else if builtins.match "22.*" version != null then "22.1"
        else version;
    in
      {
        distro = normalizedDistro;
        version = normalizedVersion;
      };

  # 根据提取的信息选择正确的源
  selectSource = systemVersion:
    let
      info = extractSystemInfo systemVersion;
    in
      if info.distro == "LineageOS" then
        if info.version == "21" then
          vendor_lindroid.LineageOS."21"
        else if info.version == "22.1" then
          vendor_lindroid.LineageOS."22.1"
        else
          (
            lib.warn "Lindroid: Unknown version '${toString info.version}' for LineageOS, defaulting to 22.1"
            vendor_lindroid.LineageOS."22.1"
          )
      else if info.distro == null && info.version != null then
        if info.version == "21" then
          vendor_lindroid.LineageOS."21"
        else if info.version == "22.1" then
          vendor_lindroid.LineageOS."22.1"
        else
          (
            lib.warn "Lindroid: Unknown version '${toString info.version}', defaulting to LineageOS 22.1"
            vendor_lindroid.LineageOS."22.1"
          )
      else if info.distro != null then
        (
          lib.warn "Lindroid: Unknown distribution '${info.distro}', defaulting to LineageOS 22.1"
          vendor_lindroid.LineageOS."22.1"
        )
      else
        (
          lib.warn "Lindroid: Unknown system version '${systemVersion}', defaulting to LineageOS 22.1"
          vendor_lindroid.LineageOS."22.1"
        );

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
        src = selectSource cfg.systemVersion;
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
