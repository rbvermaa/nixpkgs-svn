{ fetchurl, stdenv, singlePrecision ? false }:

with stdenv.lib;

let version = "3.3"; in

stdenv.mkDerivation rec {
  name = "fftw-${version}" + (if singlePrecision then "-single" else "-double");

  src = fetchurl {
    url = "ftp://ftp.fftw.org/pub/fftw/fftw-${version}.tar.gz";
    sha256 = "1skakcijq5rds6mmj7jffqk5i4fw7p81k4z1iikkx4qk3999hnnj";
  };
  
  configureFlags =
    [ "--enable-shared" "--enable-openmp" ]
    # some distros seem to be shipping both versions within the same package?
    # why does --enable-float still result in ..3f.so instead of ..3.so?
    ++ optional singlePrecision "--enable-single"
    # I think all i686 has sse
    ++ optional ((stdenv.isi686 || stdenv.isx86_64) && singlePrecision) "--enable-sse"
    # I think all x86_64 has sse2
    ++ optional (stdenv.isx86_64 && !singlePrecision) "--enable-sse2";

  meta = {
    homepage = http://www.fftw.org/;
    description = "A C subroutine library for computing the discrete Fourier transform";
  };
}
