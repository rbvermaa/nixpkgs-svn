{cabal} :

cabal.mkDerivation (self : {
  pname = "bytestring-mmap";
  version = "0.2.2";
  sha256 = "1bv9xf4cpph1cbdwv6rbmq8ppi5wjpgd97lwln5l9ky5rvnaxg3v";
  meta = {
    homepage = "http://code.haskell.org/~dons/code/bytestring-mmap/";
    description = "mmap support for strict ByteStrings";
    license = self.stdenv.lib.licenses.bsd3;
  };
})
