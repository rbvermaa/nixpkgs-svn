args: with args;
let common =
rec {
  setupHook = ./setup-hook.sh;  
  propagatedBuildInputs = [libXft libXrender libXrandr randrproto xextproto
  libXinerama xineramaproto libXcursor zlib libjpeg mysql libpng which mesa
  libXmu openssl dbus.libs cups pkgconfig libXext freetype fontconfig inputproto
  fixesproto libXfixes glib libtiff];
  prefixKey = "-prefix ";
  configureFlags = "
    -v -no-separate-debug-info -release
    -system-zlib -system-libpng -system-libjpeg -fast
    -qt-gif -confirm-license
    -opengl -xrender -xrandr -xinerama -xcursor -qt-sql-mysql
    -qdbus -cups -glib -xfixes
    -fontconfig -I${freetype}/include/freetype2";
  patchPhase = "sed -i 's@/bin/pwd@pwd@' configure; sed -i 's@/usr@/FOO@' config.tests/*/*.test mkspecs/*/*.conf";
}; in
rec {
	trolltech = stdenv.mkDerivation (common // {
	  name = "qt-4.3.3";
	  src = fetchurl {
		url = ftp://ftp.trolltech.com/qt/source/qt-x11-opensource-src-4.3.3.tar.gz;
		sha256 = "0w0mfm0wwmbj1vnjn27rza1r9wj8k47mn9ril8swprffqnn4p4w9";
	  };
	  patchPhase = common.patchPhase;
	});
	kde = stdenv.mkDerivation (common // {
	  name = "qt-kde-4.3svn";
	  src = fetchsvn {
		  url = svn://anonsvn.kde.org/home/kde/trunk/qt-copy;
		  rev = "772114";
		  sha256 = "cf8b418af39663b37726adf456ac115be5d86bdca700d65954a52042e4992acd";
	  };
	  patchPhase = "mkdir .svn; bash apply_patches;" + common.patchPhase;
	});
	default = kde;
}
