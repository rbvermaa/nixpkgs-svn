{ stdenv, fetchurl, noSysDirs
, langC ? true, langCC ? true, langF77 ? false
, profiledCompiler ? false
, binutilsCross
, kernelHeadersCross
, cross
}:

assert langC;

stdenv.mkDerivation {
  name = "gcc-4.1.2";
  builder = ./builder.sh;
  src = fetchurl {
    url = ftp://ftp.nluug.nl/pub/gnu/gcc/gcc-4.1.2/gcc-core-4.1.2.tar.bz2;
    sha256 = "07binc1hqlr0g387zrg5sp57i12yzd5ja2lgjb83bbh0h3gwbsbv";
  };
  # !!! apply only if noSysDirs is set
  patches = [./no-sys-dirs.patch] ++ (if cross == "arm-linux" then [./gcc-inhibit.patch] else []);
  #patches = [./no-sys-dirs.patch ./gcc-inhibit.patch];
  #patches = [./no-sys-dirs.patch];
  inherit noSysDirs langC langCC langF77 profiledCompiler;
  buildInputs = [binutilsCross];
  inherit kernelHeadersCross binutilsCross;
  platform = cross;

  configureFlags = "
    --disable-libssp
    --disable-multilib
    --disable-libmudflap
  ";

  meta = {
    homepage = "http://gcc.gnu.org/";
    license = "GPL/LGPL";
    description = "GNU Compiler Collection, 4.1.x (cross-compiler for " + cross + ")";
  };
}
