{ stdenv, fetchurl, pkgconfig, dbus_glib, glib, gtk, ORBit2, libxml2
, expat, policykit, intltool}:

stdenv.mkDerivation {
  name = "GConf-2.28.0";
  src = fetchurl {
    url = mirror:/gnome/sources/GConf/2.28/GConf-2.28.0.tar.bz2;
    sha256 = "1j3ah0f71yv4di3fvv1aahcjvqfwsxw2m71ljbjq0apv5gzdqmyh"
  };
  buildInputs = [ pkgconfig glib gtk dbus_glib ORBit2 libxml2
                  expat policykit intltool ];
}
