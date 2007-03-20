{stdenv, fetchurl, gccCross ? null, binutilsCross ? null, cross ? null}:

stdenv.mkDerivation {
  name = "busybox-1.4.1";
  builder = ./builder.sh;

  src = fetchurl {
    url = http://busybox.net/downloads/busybox-1.4.2.tar.bz2;
    sha256 = "03wvqba25iz264lp4q1z7rkr7q1gmzkb98xqk893w3i1kqf9n6ns";
  };

  ## this is ugly, needs improvement
  inherit cross;
  buildinputs = (if cross != "" then [gccCross] else []);
  config = config-1.4;
}
