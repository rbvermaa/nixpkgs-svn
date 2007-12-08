args: with args;

stdenv.mkDerivation (rec {
  name = "ghc-6.8.1";
  homepage = "http://www.haskell.org/ghc";

  src = map fetchurl [
    { url = "${homepage}/dist/stable/dist/${name}-src.tar.bz2";
      sha256 = "16gr19bwyjv0fmjdrsj79vqpaxxg5hasni94nwv9d6c85n5myivz";
    }
    { url = "${homepage}/dist/stable/dist/${name}-src-extralibs.tar.bz2";
      sha256 = "1h3nc6x4g838mdcirymadmv3fsmp1wh062syb3a8aqv6f468akvm";
    }
  ];

  buildInputs = [ghc readline perl m4 pkgconfig gtk];
  patchPhase = "
  sed -e s@/bin/cat@\$(type -p cat)@ -i configure
  " + 
  (if (stdenv.system == "x86_64-linx") then "patch -p2 < $patch64" else "");

  setupHook = ./setup-hook.sh;

  meta = {
    description = "The Glasgow Haskell Compiler v6.8.1";
  };

  postInstall = "
    ensureDir \"$out/nix-support\"
    echo \"# Path to the GHC compiler directory in the store\" > $out/nix-support/setup-hook
    echo \"ghc=$out\" >> $out/nix-support/setup-hook
    echo \"\"         >> $out/nix-support/setup-hook
    cat $setupHook    >> $out/nix-support/setup-hook
  ";

  patch64 = ./x86_64-linux_patch;

  # the presence of this file makes Cabal cry for happy while generating makefiles ...
  preConfigure = "
    echo 'GhcThreaded=NO' > mk/build.mk
    rm libraries/haskell-src/Language/Haskell/Parser.ly
  ";

  dontStrip = 1;
})
