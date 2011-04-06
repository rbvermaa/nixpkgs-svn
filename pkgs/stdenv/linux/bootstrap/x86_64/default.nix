# Use the static tools for i686-linux.  They work on x86_64-linux
# machines as well.
(import ../i686) //

{
  bootstrapTools = {
    url = http://www.shealevy.com/bootstrap-tools.cpio.bz2;
    sha256 = "18qg8xanrzprhy9z7z499pgwifsnrpz6shh230rbf3zg8cfgjj2x";
  };
}
