{ stdenv, fetchurl, readline, pam ? null, openldap ? null
, popt, iniparser, libunwind
, fam ? null , acl ? null, cups ? null
, useKerberos ? false, kerberos ? null, winbind ? true

# Eg. smbclient and smbspool require a smb.conf file.
# If you set configDir to "" an empty configuration file
# $out/lib/smb.conf is is created for you.
#
# configDir defaults to "/etc/samba" so that smbpassword picks up
# the location of its passwd db files from the system configuration file
# /etc/samba/smb.conf. That's why nixos touches /etc/samba/smb.conf even if you
# don't enable the samba upstart service.
, configDir ? "/etc/samba"

}:

assert useKerberos -> kerberos != null;

stdenv.mkDerivation rec {
  name = "samba-3.6.3";

  src = fetchurl {
    url = "http://us3.samba.org/samba/ftp/stable/${name}.tar.gz";
    sha256 = "0x30qv5y5m5cip077k44gf2khl0hk0s5hpy98ywmqkay5ngl1qk7";
  };

  patches =
    [
      # Allow cross-builds for GNU/Hurd.
      ./libnss-wins-pthread.patch
    ];

  buildInputs = [ readline pam openldap popt iniparser libunwind fam acl cups ]
    ++ stdenv.lib.optional useKerberos kerberos;

  enableParallelBuilding = true;

  postPatch =
    # XXX: Awful hack to allow cross-compilation.
    '' sed -i source3/configure \
           -e 's/^as_fn_error \("cannot run test program while cross compiling\)/$as_echo \1/g'
    ''; # "

  preConfigure =
    '' cd source3
       export samba_cv_CC_NEGATIVE_ENUM_VALUES=yes
       export libreplace_cv_HAVE_GETADDRINFO=yes
       export ac_cv_file__proc_sys_kernel_core_pattern=no # XXX: true on Linux, false elsewhere
    '';

  configureFlags =
    stdenv.lib.optionals (pam != null) [ "--with-pam" "--with-pam_smbpass" ]
    ++ [ "--with-aio-support"
         "--disable-swat"
         "--with-configdir=${configDir}"
         "--with-fhs"
         "--localstatedir=/var"
       ]
    ++ (stdenv.lib.optional winbind "--with-winbind")
    ++ (stdenv.lib.optional (stdenv.gcc.libc != null) "--with-libiconv=${stdenv.gcc.libc}");

  # Need to use a DESTDIR because `make install' tries to write in /var and /etc.
  installFlags = "DESTDIR=$(TMPDIR)/inst";

  stripAllList = [ "bin" "sbin" ];

  postInstall =
    ''
      mkdir -p $out
      mv $TMPDIR/inst/$out/* $out/
  
      mkdir -pv $out/lib/cups/backend
      ln -sv ../../../bin/smbspool $out/lib/cups/backend/smb
      mkdir -pv $out/etc/openldap/schema
      cp ../examples/LDAP/samba.schema $out/etc/openldap/schema
    '' # */
    + stdenv.lib.optionalString (configDir == "") "touch $out/lib/smb.conf";
}
