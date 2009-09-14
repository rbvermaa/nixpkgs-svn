{ stdenv, fetchurl, kernelHeaders
, installLocales ? true
, profilingLibraries ? false
}:

stdenv.mkDerivation rec {
  name = "glibc-2.9";

  builder = ./builder.sh;

  src = fetchurl {
    url = http://ftp.gnu.org/gnu/glibc/glibc-2.9.tar.bz2;
    sha256 = "0v53m7flx6qcx7cvrvvw6a4dx4x3y6k8nvpc4wfv5xaaqy2am2q9";
  };

  srcPorts = fetchurl {
    url = http://ftp.gnu.org/gnu/glibc/glibc-ports-2.9.tar.bz2;
    sha256 = "0r2sn527wxqifi63di7ns9wbjh1cainxn978w178khhy7yw9fk42";
  };

  inherit kernelHeaders installLocales;

  inherit (stdenv) is64bit;

  patches = [
    /* Fix for NIXPKGS-79: when doing host name lookups, when
       nsswitch.conf contains a line like

         hosts: files mdns4_minimal [NOTFOUND=return] dns mdns4

       don't return an error when mdns4_minimal can't be found.  This
       is a bug in Glibc: when a service can't be found, NSS should
       continue to the next service unless "UNAVAIL=return" is set.
       ("NOTFOUND=return" refers to the service returning a NOTFOUND
       error, not the service itself not being found.)  The reason is
       that the "status" variable (while initialised to UNAVAIL) is
       outside of the loop that iterates over the services, the
       "files" service sets status to NOTFOUND.  So when the call to
       find "mdns4_minimal" fails, "status" will still be NOTFOUND,
       and it will return instead of continuing to "dns".  Thus, the
       line

         hosts: mdns4_minimal [NOTFOUND=return] dns mdns4

       does work because "status" will contain UNAVAIL after the
       failure to find mdns4_minimal. */
    ./nss-skip-unavail.patch

    /* Make it possible to override the locale-archive in NixOS. */
    ./locale-override.patch

    /* Have rpcgen(1) look for cpp(1) in $PATH.  */
    ./rpcgen-path.patch
  ];

  configureFlags = [
    "--with-headers=${kernelHeaders}/include"
    "--without-fp"
    (if profilingLibraries then "--enable-profile" else "--disable-profile")
    "--enable-add-ons"
    "--host=arm-linux-gnueabi"
    "--build=arm-linux-gnueabi"
  ];

  preInstall = ''
    ensureDir $out/lib
    ln -s ${stdenv.gcc.gcc}/lib/libgcc_s.so.1 $out/lib/libgcc_s.so.1
  '';

  postInstall = ''
    rm $out/lib/libgcc_s.so.1
  '';

  # Workaround for this bug:
  #   http://sourceware.org/bugzilla/show_bug.cgi?id=411
  # I.e. when gcc is compiled with --with-arch=i686, then the
  # preprocessor symbol `__i686' will be defined to `1'.  This causes
  # the symbol __i686.get_pc_thunk.dx to be mangled.
  NIX_CFLAGS_COMPILE = "-U__i686";

  meta = {
    homepage = http://www.gnu.org/software/libc/;
    description = "The GNU C Library";
  };
}
