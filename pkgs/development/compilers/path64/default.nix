{stdenv, fetchgit, perl, flex, bison, gmp, mpfr, cmake}:

stdenv.mkDerivation {
  name = "path64-2010-07-02";

  src = fetchgit {
    url = git://github.com/path64/compiler.git;
    rev = "e17f7f952831bbf1d996";
    sha256 = "fa1320959e1131557d5f82e98f4621a222ec45e1d6e0e7f271d2c13de4fd0dd1";
  };

  cmakeFlags = "
    -DPATH64_ENABLE_HUGEPAGES=ON 
    -DPATH64_ENABLE_MATHLIBS=ON -DPATH64_ENABLE_OPENMP=ON 
    -DPATH64_ENABLE_PSCRUNTIME=OFF -DPSC_CRT_PATH=/usr/lib64 
    -DPATH64_ENABLE_PROFILING=OFF -DPATH64_ENABLE_TARGETS=x8664 
    -DCMAKE_BUILD_TYPE=Debug -DPATH64_ENABLE_FORTRAN=OFF
  ";

  makeFlags = "-j4";

  buildInputs = [ perl flex bison gmp mpfr cmake ];
}
