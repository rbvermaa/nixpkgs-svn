{stdenv, fetchurl, gmp}:

stdenv.mkDerivation {
  name = "mpfr-2.4.0";

  src = fetchurl {
    urls = [
      http://gforge.inria.fr/frs/download.php/16015/mpfr-2.4.0.tar.bz2
      http://www.mpfr.org/mpfr-2.4.0/mpfr-2.4.0.tar.bz2
    ];
    sha256 = "17ajw12jfs721igsr6ny3wxz9j1nm618iplc82wyzins5gn52gdy";
  };

  buildInputs = [gmp];

  meta = {
    homepage = http://www.mpfr.org/;
    description = "GNU MPFR, a library for multiple-precision floating-point arithmetic";

    longDescription = ''
      The GNU MPFR library is a C library for multiple-precision
      floating-point computations with correct rounding.  MPFR is
      based on the GMP multiple-precision library.

      The main goal of MPFR is to provide a library for
      multiple-precision floating-point computation which is both
      efficient and has a well-defined semantics.  It copies the good
      ideas from the ANSI/IEEE-754 standard for double-precision
      floating-point arithmetic (53-bit mantissa).
    '';

    license = "LGPLv2+";
  };
}
