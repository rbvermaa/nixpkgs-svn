# Use the static tools for i686-linux.  They work on x86_64-linux
# machines as well.
(import ../i686) //

{
  bootstrapTools = {
    url = http://www.shealevy.com/nix/1/bootstrap-tools.cpio.bz2;
    sha256 = "0qvmz48ba10g0q5fl3rgqpf3yfzr13aflk08f1hxdb2hqbf164dj";
  };
}
