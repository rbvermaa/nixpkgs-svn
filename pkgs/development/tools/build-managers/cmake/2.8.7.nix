{ fetchurl, stdenv, replace, curl, expat, zlib, bzip2, libarchive
, useNcurses ? false, ncurses, useQt4 ? false, qt4
, darwinInstallNameToolUtility }:

with stdenv.lib;

let
  os = stdenv.lib.optionalString;
  majorVersion = "2.8";
  minorVersion = "7";
  version = "${majorVersion}.${minorVersion}";
in

# WARNING: Do NOT upgrade cmake in trunk: it fails to build on i686-linux
stdenv.mkDerivation rec {
  name = "cmake-${os useNcurses "cursesUI-"}${os useQt4 "qt4UI-"}${version}";

  inherit majorVersion;

  src = fetchurl {
    url = "${meta.homepage}files/v${majorVersion}/cmake-${version}.tar.gz";
    sha256 = "130923053d8fe1a2ae032a3f09021f9024bf29d7a04ed10ae04647ff00ecf59f";
  };

  patches =
    # Don't search in non-Nix locations such as /usr, but do search in
    # Nixpkgs' Glibc.
    optional (stdenv ? glibc) ./search-path.patch;

  buildInputs = [ curl expat zlib bzip2 libarchive ]
    ++ optional stdenv.isDarwin darwinInstallNameToolUtility
    ++ optional useNcurses ncurses
    ++ optional useQt4 qt4;

  CMAKE_PREFIX_PATH = stdenv.lib.concatStringsSep ":" buildInputs;
  
  configureFlags =
    "--docdir=/share/doc/${name} --mandir=/share/man --system-libs"
    + stdenv.lib.optionalString useQt4 " --qt-gui";

  setupHook = ./setup-hook.sh;

  postUnpack =
    ''
      dontUseCmakeConfigure=1
      source $setupHook
      fixCmakeFiles $sourceRoot
    '';

  preConfigure = optionalString (stdenv ? glibc)
    ''
      substituteInPlace Modules/Platform/UnixPaths.cmake --subst-var-by glibc ${stdenv.glibc}
    '';

  meta = {
    homepage = http://www.cmake.org/;
    description = "Cross-Platform Makefile Generator";
    platforms = if useQt4 then qt4.meta.platforms else stdenv.lib.platforms.all;
    maintainers = [ stdenv.lib.maintainers.urkud ];
  };
}
