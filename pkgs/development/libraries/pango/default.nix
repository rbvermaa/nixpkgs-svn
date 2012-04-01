{ stdenv, fetchurl, pkgconfig, gettext, x11, glib, cairo, libpng }:

stdenv.mkDerivation rec {
  name = "pango-1.30.0";

  src = fetchurl {
    url = mirror://gnome/sources/pango/1.30/pango-1.30.0.tar.xz;
    sha256 = "1zrd23s8gls8ixl51z6r6rm9qpr332w7k4igjh7fvymg4jq2lvbw";
  };

  buildInputs = stdenv.lib.optional stdenv.isDarwin gettext;

  buildNativeInputs = [ pkgconfig ];

  propagatedBuildInputs = [ x11 glib cairo libpng ];

  postInstall = "rm -rf $out/share/gtk-doc";

  meta = {
    description = "A library for laying out and rendering of text, with an emphasis on internationalization";

    longDescription = ''
      Pango is a library for laying out and rendering of text, with an
      emphasis on internationalization.  Pango can be used anywhere
      that text layout is needed, though most of the work on Pango so
      far has been done in the context of the GTK+ widget toolkit.
      Pango forms the core of text and font handling for GTK+-2.x.
    '';

    homepage = http://www.pango.org/;
    license = "LGPLv2+";

    maintainers = with stdenv.lib.maintainers; [ raskin urkud ];
    platforms = stdenv.lib.platforms.all;
  };
}
