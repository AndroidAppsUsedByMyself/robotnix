{ config, pkgs, lib, ... }:

with lib;
{
  # It's convenient to have this all in one file, instead of separately in 9/default.nix, 10/default.nix, etc
  # Check build/soong/ui/build/paths/config.go for a list of things that are needed
  envPackages = with pkgs; mkMerge ([
    [
      bc
      git
      gnumake
      jre8_headless
      lsof
      m4
      ncurses5
      openssl # Used in avbtool
      psmisc # for "fuser", "pstree"
      rsync
      unzip
      zip

      # Things not in build/soong/ui/build/paths/config.go
      nettools # Needed for "hostname" in build/soong/ui/build/sandbox_linux.go
      procps # Needed for "ps" in build/envsetup.sh
    ]
    (mkIf (config.androidVersion >= 10) [
      freetype # Needed by jdk9 prebuilt
      fontconfig

      python3
      python2 # device/generic/goldfish/tools/mk_combined_img.py still needs py2 :(
    ])
    (mkIf (config.androidVersion <= 9) [
      # stuff that was in the earlier buildenv. Not entirely sure everything here is necessary
      (androidPkgs.sdk (p: with p; [ cmdline-tools-latest platform-tools ]))
      openssl.dev
      bison
      curl
      flex
      gcc
      gitRepo
      gnupg
      gperf
      imagemagick
      libxml2
      lzip
      lzop
      perl
      python2
      schedtool
      utillinux
      which
    ])
  ]);
}
