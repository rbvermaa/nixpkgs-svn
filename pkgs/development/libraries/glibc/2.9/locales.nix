/* This function builds just the `lib/locale/locale-archive' file from
   Glibc and nothing else.  If `allLocales' is true, all supported
   locales are included; otherwise, just the locales listed in
   `locales'.  See localedata/SUPPORTED in the Glibc source tree for
   the list of all supported locales:
   http://sourceware.org/cgi-bin/cvsweb.cgi/libc/localedata/SUPPORTED?cvsroot=glibc
*/

{ stdenv, fetchurl, allLocales ? true, locales ? ["en_US.UTF-8/UTF-8"] }:

stdenv.mkDerivation rec {
  name = "glibc-locales-2.9";

  builder = ./localesbuilder.sh;

  src = fetchurl {
    url = http://ftp.gnu.org/gnu/glibc/glibc-2.9.tar.bz2;
    sha256 = "0v53m7flx6qcx7cvrvvw6a4dx4x3y6k8nvpc4wfv5xaaqy2am2q9";
  };

  srcPorts = fetchurl {
    url = http://ftp.gnu.org/gnu/glibc/glibc-ports-2.9.tar.bz2;
    sha256 = "0r2sn527wxqifi63di7ns9wbjh1cainxn978w178khhy7yw9fk42";
  };

  inherit (stdenv) is64bit;

  configureFlags = [
    "--enable-add-ons"
    "--without-headers"
    "--disable-profile"
  ] ++ (if (stdenv.system == "armv5tel-linux") then [
    "--host=arm-linux-gnueabi"
    "--build=arm-linux-gnueabi"
    "--without-fp"
  ] else []);

  patches = [
    /* Support GNU Binutils 2.20 and above.  */
    ./binutils-2.20.patch
  ];

  # Awful hack: `localedef' doesn't allow the path to `locale-archive'
  # to be overriden, but you *can* specify a prefix, i.e. it will use
  # <prefix>/<path-to-glibc>/lib/locale/locale-archive.  So we use
  # $TMPDIR as a prefix, meaning that the locale-archive is placed in
  # $TMPDIR/nix/store/...-glibc-.../lib/locale/locale-archive.
  buildPhase =
    ''
      mkdir -p $TMPDIR/"$(dirname $(readlink -f $(type -p localedef)))/../lib/locale"
      make localedata/install-locales \
          LOCALEDEF="localedef --prefix=$TMPDIR" \
          localedir=$out/lib/locale \
          ${if allLocales then "" else "SUPPORTED-LOCALES=\"${toString locales}\""}
    '';

  installPhase =
    ''
      mkdir -p $out/lib/locale
      cp $TMPDIR/nix/store/*/lib/locale/locale-archive $out/lib/locale/
    '';

  meta = {
    homepage = http://www.gnu.org/software/libc/;
    description = "Locale information for the GNU C Library";
  };
}
