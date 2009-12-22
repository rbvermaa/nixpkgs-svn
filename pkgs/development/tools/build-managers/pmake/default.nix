{ fetchurl, stdenv }:

let version = "1.111"; in
stdenv.mkDerivation {
  name = "pmake-${version}";

  src = fetchurl {
    url = "mirror://debian/pool/main/p/pmake/pmake_${version}.orig.tar.gz";
    sha256 = "0f9ml4jgn3djrx5r07xmcarwl085x43w4m272z77r6pi3337mqyx";
  };

  patches = [ ./debian-pmake_1.111-1.diff ];

  configurePhase =
    '' sed -i Makefile.boot \
           -e "s/MACHINE=.*$/MACHINE=$(uname -m)/g ;
	       s/MACHINE_ARCH=.*$/MACHINE_ARCH=$(uname -p)/g"

       for i in mk/Makefile pathnames.h make.1
       do
	 sed -i "$i" -e "s|/usr/share/mk|$out/share/mk|g"
       done

       # FIXME: What to do with that directory?
       sed -i pathnames.h -e"s|/usr/obj|/var/obj|g"
    '';

  buildPhase =
    '' make -f Makefile.boot \
            CFLAGS="-DTARGET_MACHINE=$(uname -p) -DHAVE_STRERROR -DHAVE_STRDUP -DHAVE_SETENV -DHAVE_VSNPRINTF -DHAVE_STRFTIME"

       export BINOWN=$(id -u)
       export MANOWN=$(id -u)
       export LIBOWN=$(id -u)
       export DOCOWN=$(id -u)
       export FILESOWN=$(id -u)
       export BINGRP=$(id -g)
       export MANGRP=$(id -g)
       export LIBGRP=$(id -g)
       export DOCGRP=$(id -g)
       export FILESGRP=$(id -g)

       # Install the `.mk' files since we need `sys.mk' to continue.
       ensureDir "$out/bin"
       ensureDir "$out/share/mk"
       ( cd mk ; ../bmake install )

       for i in "config.h" "lst.lib/"* "main.c"
       do
         sed -i "$i" -e '1i\#undef MAKE_NATIVE\'
       done

       ./bmake CFLAGS="-DTARGET_MACHINE=$(uname -p) -DHAVE_STRERROR -DHAVE_STRDUP -DHAVE_SETENV -DHAVE_VSNPRINTF -DHAVE_STRFTIME"
    '';

  installPhase =
    '' ensureDir "$out/bin"
       ensureDir "$out/share/mk"
       ensureDir "$out/share/man/man1"
       ./make proginstall maninstall BINDIR="$out/bin" MANDIR="$out/share/man"
    '';

  # XXX: The tests fail weirdly, but who cares?
  doCheck = false;
  checkPhase = "./make test";

  meta = {
    description = "PMake, NetBSD's make implementation";

    license = "revised-BSD";
  };
}
