{ stdenv, fetchurl, pkgconfig, glib, libtiff, libjpeg, libpng, libX11, xz
, jasper, shared_mime_info }:

stdenv.mkDerivation {
  name = "gdk-pixbuf-2.26.0";

  src = fetchurl {
    url = mirror://gnome/sources/gdk-pixbuf/2.26/gdk-pixbuf-2.26.0.tar.xz;
    sha256 = "0k959w31wqkk4jsvbxyzczq3far5dqdmdg34c9nbn33i6cx8s0m5";
  };

  # !!! We might want to factor out the gdk-pixbuf-xlib subpackage.
  buildInputs = [ libX11 ];

  buildNativeInputs = [ pkgconfig shared_mime_info ];

  propagatedBuildInputs = [ glib libtiff libjpeg libpng jasper ];

  configureFlags = "--with-libjasper --with-x11";

  meta = {
    description = "A library for image loading and manipulation";

    homepage = http://library.gnome.org/devel/gdk-pixbuf/;

    maintainers = with stdenv.lib.maintainers; [ eelco urkud ];
    platforms = stdenv.lib.platforms.linux;
  };
}
