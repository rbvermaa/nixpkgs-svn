{ stdenv, fetchsvn, kernelHeaders
, installLocales ? true
, profilingLibraries ? false
}:

stdenv.mkDerivation rec {
  name = "eglibc-2.10";

  src = fetchsvn {
    url = svn://svn.eglibc.org/branches/eglibc-2_10;
    rev = 8690;
    sha256 = "029hklrx2rlhsb5r2csd0gapjm0rbr8n28ib6jnnhms12x302viq";
  };

  preConfigure = ''
    cd libc
  '';

  inherit kernelHeaders installLocales;

  configureFlags = ''
    --with-headers=${kernelHeaders}/include
    --without-fp
    --enable-add-ons
    --disable-profile
  '';

  configurePhase = ''
    cd libc
    ln -s ../ports ports
    mkdir build
    cd build
    ../configure ${configureFlags}
  '';

#  configureFlags = ''
#    --enable-add-ons
#    --with-headers=${kernelHeaders}/include
#    --without-fp
#    --disable-libunwind-exceptions
#    ${if profilingLibraries then "--enable-profile" else "--disable-profile"}
#  '';

  meta = {
    homepage = http://www.gnu.org/software/libc/;
    description = "The GNU C Library";
  };
}
