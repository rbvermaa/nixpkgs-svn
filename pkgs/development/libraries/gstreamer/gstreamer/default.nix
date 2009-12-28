{ fetchurl, stdenv, perl, bison, flex, pkgconfig, python
, which, gtkdoc, glib, libxml2, ... }:

stdenv.mkDerivation rec {
  name = "gstreamer-0.10.25";

  src = fetchurl {
    urls = [
      "${meta.homepage}/src/gstreamer/${name}.tar.bz2"
      "mirror://gentoo/distfiles/${name}.tar.bz2"
      ];
    sha256 = "0y35a9b2m66rsxlkksakdbimfxy2j5q1wim9k3czd3gs7dxvmcir";
  };

  buildInputs = [perl bison flex pkgconfig python which  gtkdoc ];
  propagatedBuildInputs = [glib libxml2];

  configureFlags = ''
    --enable-failing-tests --localstatedir=/var --disable-gtk-doc --disable-docbook
  '';

  meta = {
    homepage = http://gstreamer.freedesktop.org;

    description = "GStreamer, a library for constructing graphs of media-handling components";

    longDescription = ''
      GStreamer is a library for constructing graphs of media-handling
      components.  The applications it supports range from simple
      Ogg/Vorbis playback, audio/video streaming to complex audio
      (mixing) and video (non-linear editing) processing.

      Applications can take advantage of advances in codec and filter
      technology transparently.  Developers can add new codecs and
      filters by writing a simple plugin with a clean, generic
      interface.
    '';

    license = "LGPLv2+";
  };
}
