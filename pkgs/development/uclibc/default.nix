{stdenv, fetchurl, gccCross, kernelHeadersCross, binutilsCross, cross, mktemp}:

stdenv.mkDerivation {
  builder = ./builder.sh;
  name = "uClibc-0.9.28.3";
  src = fetchurl {
    #url = http://www.uclibc.org/downloads/snapshots/uClibc-20060302.tar.bz2;
    #md5 = "3502da5973851a63625791545d459734";
    url = http://www.uclibc.org/downloads/uClibc-0.9.28.3.tar.bz2;
    sha256 = "18a7nmshl7458xsb64jix5zxq6v6nz3zy8z0rxbp03h6svddb1hx";
  };
  config = if cross == "mips-linux"
             then ./config-mips-linux
           else if cross == "arm-linux"
                  then ./config-arm-linux
                else if cross == "sparc-linux"
                    then ./config-sparc-linux
                else if cross == "powerpc-linux"
                    then ./config-powerpc-linux
                      else "";

  inherit kernelHeadersCross;
  buildInputs = [gccCross binutilsCross mktemp];
  inherit cross;
  dontStrip = true;
}
