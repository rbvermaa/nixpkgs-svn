{stdenv, fetchurl}:

stdenv.mkDerivation {
  name = "gperf-2.7.2";
  builder = ./builder.sh;
  src = fetchurl {
    url = ftp://ftp.gnu.org/gnu/gperf/gperf-2.7.2.tar.gz;
    md5 = "e501acc2e18eed2c8f25ca0ac2330d68";
  };
}
