{ stdenv, fetchurl, lib, cmake, qt4, perl, libxml2, libxslt, boost, shared_mime_info
, kdelibs, kdelibs_experimental, kdepimlibs
, automoc4, phonon, akonadi, soprano, strigi}:

stdenv.mkDerivation {
  name = "kdepim-runtime-4.3.1";
  src = fetchurl {
    url = mirror://kde/stable/4.3.1/src/kdepim-runtime-4.3.1.tar.bz2;
    sha1 = "c39b0fc1d3721fb8c6074ba6a174ad8716c6c604";
  };
  buildInputs = [ cmake qt4 perl libxml2 libxslt boost shared_mime_info
                  kdelibs kdelibs_experimental kdepimlibs
		  automoc4 phonon akonadi soprano strigi ];
  CMAKE_PREFIX_PATH=kdepimlibs;
  includeAllQtDirs=true;
  meta = {
    description = "KDE PIM runtime";
    homepage = http://www.kde.org;
    license = "GPL";
    maintainers = [ lib.maintainers.sander ];
  };
}
