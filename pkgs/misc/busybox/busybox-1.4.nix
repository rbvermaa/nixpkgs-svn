{stdenv, fetchurl, gccCross ? null, binutilsCross ? null, cross ? null}:

stdenv.mkDerivation {
  name = "busybox-1.4.1";
  builder = ./builder.sh;

  src = fetchurl {
    url = http://busybox.net/downloads/busybox-1.4.2.tar.bz2;
    sha256 = "03wvqba25iz264lp4q1z7rkr7q1gmzkb98xqk893w3i1kqf9n6ns";
  };

  inherit gccCross;
  buildinputs = [(if cross != "" then binutilsCross else null)];
  # fixme, need a decent config for MIPS or so
  config = ./x86-config-1.4;
}
