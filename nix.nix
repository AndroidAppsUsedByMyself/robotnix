{ lib, fetchurl, fetchFromGitHub, callPackage
, storeDir ? "/nix/store"
, stateDir ? "/nix/var"
, confDir ? "/etc"
, boehmgc
}:

let

common =
  { lib, stdenv, fetchurl, fetchpatch, perl, curl, bzip2, sqlite, openssl ? null, xz
  , pkgconfig, boehmgc, perlPackages, libsodium, brotli, boost, editline
  , autoreconfHook, autoconf-archive, bison, flex, libxml2, libxslt, docbook5, docbook_xsl_ns
  , busybox-sandbox-shell
  , storeDir
  , stateDir
  , confDir
  , withLibseccomp ? lib.any (lib.meta.platformMatch stdenv.hostPlatform) libseccomp.meta.platforms, libseccomp
  , withAWS ? stdenv.isLinux || stdenv.isDarwin, aws-sdk-cpp

  , name, suffix ? "", src, includesPerl ? false, fromGit ? false

  }:
  let
     sh = busybox-sandbox-shell;
     nix = stdenv.mkDerivation rec {
      inherit name src;
      version = lib.getVersion name;

      is20 = lib.versionAtLeast version "2.0pre";

      VERSION_SUFFIX = lib.optionalString fromGit suffix;

      outputs = [ "out" "dev" "man" "doc" ];

      nativeBuildInputs =
        [ pkgconfig ]
        ++ lib.optionals (!is20) [ curl perl ]
        ++ lib.optionals fromGit [ autoreconfHook autoconf-archive bison flex libxml2 libxslt docbook5 docbook_xsl_ns ];

      buildInputs = [ curl openssl sqlite xz bzip2 ]
        ++ lib.optional (stdenv.isLinux || stdenv.isDarwin) libsodium
        ++ lib.optionals is20 [ brotli boost editline ]
        ++ lib.optional withLibseccomp libseccomp
        ++ lib.optional (withAWS && is20)
            ((aws-sdk-cpp.override {
              apis = ["s3" "transfer"];
              customMemoryManagement = false;
            }).overrideDerivation (args: {
              patches = args.patches or [] ++ [(fetchpatch {
                url = https://github.com/edolstra/aws-sdk-cpp/commit/7d58e303159b2fb343af9a1ec4512238efa147c7.patch;
                sha256 = "103phn6kyvs1yc7fibyin3lgxz699qakhw671kl207484im55id1";
              })];
            }));

      propagatedBuildInputs = [ boehmgc ];

      # Seems to be required when using std::atomic with 64-bit types
      NIX_LDFLAGS = lib.optionalString (stdenv.hostPlatform.system == "armv6l-linux") "-latomic";

      preConfigure =
        # Copy libboost_context so we don't get all of Boost in our closure.
        # https://github.com/NixOS/nixpkgs/issues/45462
        if is20 then ''
          mkdir -p $out/lib
          cp ${boost}/lib/libboost_context* $out/lib
        '' else ''
          configureFlagsArray+=(BDW_GC_LIBS="-lgc -lgccpp")
        '';

      configureFlags =
        [ "--with-store-dir=${storeDir}"
          "--localstatedir=${stateDir}"
          "--sysconfdir=${confDir}"
          "--disable-init-state"
          "--enable-gc"
        ]
        ++ lib.optionals (!is20) [
          "--with-dbi=${perlPackages.DBI}/${perl.libPrefix}"
          "--with-dbd-sqlite=${perlPackages.DBDSQLite}/${perl.libPrefix}"
          "--with-www-curl=${perlPackages.WWWCurl}/${perl.libPrefix}"
        ] ++ lib.optionals (is20 && stdenv.isLinux) [
          "--with-sandbox-shell=${sh}/bin/busybox"
        ]
        ++ lib.optional (
            stdenv.hostPlatform != stdenv.buildPlatform && stdenv.hostPlatform ? nix && stdenv.hostPlatform.nix ? system
        ) ''--with-system=${stdenv.hostPlatform.nix.system}''
           # RISC-V support in progress https://github.com/seccomp/libseccomp/pull/50
        ++ lib.optional (!withLibseccomp) "--disable-seccomp-sandboxing";

      makeFlags = "profiledir=$(out)/etc/profile.d";

      installFlags = "sysconfdir=$(out)/etc";

      doInstallCheck = false; # not cross

      # socket path becomes too long otherwise
      preInstallCheck = lib.optional stdenv.isDarwin ''
        export TMPDIR=$NIX_BUILD_TOP
      '';

      separateDebugInfo = stdenv.isLinux;

      enableParallelBuilding = true;

      meta = {
        description = "Powerful package manager that makes package management reliable and reproducible";
        longDescription = ''
          Nix is a powerful package manager for Linux and other Unix systems that
          makes package management reliable and reproducible. It provides atomic
          upgrades and rollbacks, side-by-side installation of multiple versions of
          a package, multi-user package management and easy setup of build
          environments.
        '';
        homepage = https://nixos.org/;
        license = stdenv.lib.licenses.lgpl2Plus;
        maintainers = [ stdenv.lib.maintainers.eelco ];
        platforms = stdenv.lib.platforms.all;
        outputsToInstall = [ "out" "man" ];
      };

      passthru = {
        inherit fromGit;

        perl-bindings = if includesPerl then nix else stdenv.mkDerivation {
          name = "nix-perl-${version}";

          inherit src;

          postUnpack = "sourceRoot=$sourceRoot/perl";

          # This is not cross-compile safe, don't have time to fix right now
          # but noting for future travellers.
          nativeBuildInputs =
            [ perl pkgconfig curl nix libsodium ]
            ++ lib.optionals fromGit [ autoreconfHook autoconf-archive ]
            ++ lib.optional is20 boost;

          configureFlags =
            [ "--with-dbi=${perlPackages.DBI}/${perl.libPrefix}"
              "--with-dbd-sqlite=${perlPackages.DBDSQLite}/${perl.libPrefix}"
            ];

          preConfigure = "export NIX_STATE_DIR=$TMPDIR";

          preBuild = "unset NIX_INDENT_MAKE";
        };
      };
    };
  in nix;

in rec {

  nix = callPackage common rec {
    name = "nix-2.3${suffix}";
    suffix = "pre6631_e58a7144";
    src = fetchFromGitHub {
      owner = "ajs124";
      repo = "nix";
      rev = "e3e6c1a8afceae4750223e119319da5a5b62b01e";
      sha256 = "1jfcyba01xw2227w3r3af0p40hwc5fliymjfwpsxi78z8m77r6x4";
    };
    fromGit = true;

    inherit storeDir stateDir confDir boehmgc;
  };

}
