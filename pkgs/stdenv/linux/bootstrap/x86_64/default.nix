# Use the static tools for i686-linux.  They work on x86_64-linux
# machines as well.
(import ../i686) //

{
  bootstrapTools = {
    url = http://www.shealevy.com/nix/1/bootstrap-tools.cpio.bz2;
    sha256 = "1x9vqycqg41l3f167scl5nmflgmysx4a65afdz7zds4m0y27va0g";
  };
}
