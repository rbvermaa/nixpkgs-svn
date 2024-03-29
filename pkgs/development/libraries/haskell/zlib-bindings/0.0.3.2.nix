{ cabal, zlib }:

cabal.mkDerivation (self: {
  pname = "zlib-bindings";
  version = "0.0.3.2";
  sha256 = "0x78fkjinfhhihhfihr0g5rc4d8jkhza3vw5qsyds74skd6rsy1q";
  buildDepends = [ zlib ];
  meta = {
    homepage = "http://github.com/snoyberg/zlib-bindings";
    description = "Low-level bindings to the zlib package";
    license = self.stdenv.lib.licenses.bsd3;
    platforms = self.ghc.meta.platforms;
    maintainers = [ self.stdenv.lib.maintainers.andres ];
  };
})
