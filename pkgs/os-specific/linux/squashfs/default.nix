{stdenv, fetchurl, zlib}:

stdenv.mkDerivation {
  name = "squashfs-3.2-r2";
  builder = ./builder.sh;
  src = fetchurl {
    url = http://switch.dl.sourceforge.net/sourceforge/squashfs/squashfs3.2-r2.tar.gz;
    sha256 = "19s01d2wsqy4d3f5wjwkywy8qz0zj8sc0bxk1339k06pb1fld0l4";
  };
  buildInputs = [zlib];
}
