{stdenv, fetchurl, cross}:

assert stdenv.system == "i686-linux";

stdenv.mkDerivation {
  name = "linux-headers-2.6.19.7";
  builder = ./builder.sh;
  src = fetchurl {
    url = ftp://ftp.nluug.nl/pub/os/Linux/system/kernel/v2.6/linux-2.6.19.7.tar.bz2;
    sha256 = "1ygspwl019d4aypn3kd0pp9r3650aslm6zpfdspp1v575l6gcmy8";
  };
  inherit cross;
}
