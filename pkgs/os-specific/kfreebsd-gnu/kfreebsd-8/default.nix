{ fetchurl, stdenv, pmake }:

let
   lib = stdenv.lib;

   major   = "8";
   version = "8.0-1";
   configfile = "NIXOS-CUSTOM";

   # SVN revision of the glibc-bsd repository at svn.debian.org.
   debianRevision = "2862";

   fetchpatch = name: sha256:
     fetchurl {
       url = "http://svn.debian.org/viewsvn/glibc-bsd/trunk/kfreebsd-8"
             + "/debian/patches/${name}?revision=${debianRevision}";
       inherit name sha256;
     };

   patches = [
    (fetchpatch "000_rename.diff" "16g4s1vxifwdr6fc2ayadsmqxarw9lp5zhq8i226gwa7xnxi1s5r")
    (fetchpatch "001_misc.diff" "119qwqr4ibkni0pibzn3c4ychsyk71cp4bx63k3dwrz9nxksiin6")
    (fetchpatch "003_glibc_dev_aicasm.diff" "0088pz81wy4s2zd9pfvylqxjn8p4qr1y6pqh11f61hy87xa5v9ii")
    (fetchpatch "004_xargs.diff" "0d5prmyi5n9a5amba5hls4sag334rdv4v2y56vbzbhbn1caahsfn")
    (fetchpatch "007_clone_signals.diff" "0146x4j3i3s7xvhfrgq137cckgl10w93gx0qdr72blcfa70h5nsy")
    (fetchpatch "008_config.diff" "1s832zzsq060109gwskb5kb2sr3fbfkgiggbklszn31vx6bbi9xa")
    (fetchpatch "009_disable_duped_modules.diff" "19bm7gaf0xql3yfk7sgs8lmil1470vb14cx77bh9infiija96j78")
    (fetchpatch "013_ip_packed.diff" "0ad2qv083fc1fnmyf3kw0ypfaym22675pczh24k9ifnfkhigg4qi")
    (fetchpatch "020_linker.diff" "14hi0sh3rkicfkdzj4rrxh6l7kqadfzbl4x3yr58p4x1h0mvsvf0")
    (fetchpatch "102_POLL_HUP.diff" "1x47mcgqr2fd9ikwqg8whmixjia1biqv774zf9a4p8zjlmmrlkmh")
    (fetchpatch "103_stat_pipe.diff" "1zl405fh5xmb21hwggjh5dqdd3fl5k4dibxzb1dgp38qsfl2li76")
    (fetchpatch "902_version.diff" "0byf87vd7xh4yyr1yyj88b3g006gnl5slrvnfh9y9qk3mr5w6q8l")
    (fetchpatch "903_disable_non-free_drivers.diff" "1fvsf0shvlqnygrs3raagmim5sb85g2m9bcf73n0mwkhvd05iyml")
    (fetchpatch "904_dev_full.diff" "1j63a584i2887i4nhskwg8jhlbvlnnb99c894h795qxlqzgxlvh0")
    (fetchpatch "906_grow_sysv_ipc_limits.diff" "1dcbqi24n68j13m22fa1q1bv6f6r6a9jxsv4kq89m2lh0gqkzfwv")
    (fetchpatch "907_cpu_class.diff" "04cjsgnvv61yhiw5jcyc78jz9b8l0kjb623lafy7zfxp05i8yy5f")
    (fetchpatch "908_linprocfs_is_not_proc.diff" "0jjdqns0c3lk7l16wpq2kkbjyq8jnahv76dqpdlawgavzk5nrj9q")
    (fetchpatch "910_GENERIC_hints.diff" "1rabrhj9yj9536bfkkyqxhw4h5925kx30nim420krq4ay3m9k3vn")
    (fetchpatch "912_binutils.diff" "1yjj7f55lf35a9p0cn098yrkzmcrcgrin3cydghrlw728brrbpg1")
    (fetchpatch "913_uudecode.diff" "1i4gk5v0yjjiavnr8dibhikf3chxqlvzls3w6a5d8l1a20mca8my")
    (fetchpatch "914_psm.diff" "0gxqhyi6bazqjqms8xr0g2wq84fgwvf2dnfk515y34glgmfm4d7s")
    (fetchpatch "950_no_stack_protector.diff" "0rn6q8najjip9vk91yizzlrrjia3rqzhvwinsln5grl5446p5abd")
    (fetchpatch "999_config.diff" "1n268q6fyxiwch8pgn45x56ag93gdri6n8fb0a9gwg8hy8fs2n9p")
  ];

  fetchconfig = arch: name: sha256:
    fetchurl {
      url = "http://svn.debian.org/viewsvn/glibc-bsd/trunk/kfreebsd-8"
            + "/debian/arch/${arch}/${name}?revision=${debianRevision}";
      inherit name sha256;
    };

  i686smpConfig =
    fetchconfig "i386" "686-smp.config" "1y5x3h6d4amydzl8slysi8zlxxl4lal1w32l1kllla2q51nc7b0v";
  x86_64Config =
    fetchconfig "amd64" "amd64.config" "1nwlkc7qd4pjcslm2yqyc07pp13m7p8l10wkjb1kqx3f91j49df8";
  config = if stdenv.isi686
           then i686smpConfig
           else x86_64Config;
in
# FIXME: We need `freebsd-buildutils' and `libbsd-dev'.
builtins.trace "WARNING: This is work in progress!"
stdenv.mkDerivation rec {
  name = "kfreebsd-${version}";

  src = fetchurl {
    url = "mirror://debian/pool/main/k/kfreebsd-8/kfreebsd-8_8.0.orig.tar.gz";
    sha256 = "1pvwll4vkr0av5iajw0csaq6xqkrwr92jf29dy6m7lns1ff428am";
  };

  buildInputs = [ pmake ];

  patchPhase =
    # Adapted from `debian/rules'.
    '' ${lib.concatStrings
         (builtins.map (p:
          '' echo "applying patch \`${p}'..."
             patch -p1 < "${p}"
          '')
          patches)}

       mkdir src
       mv -v sys usr.sbin src

       find src -type f -exec \
            sed -i "{}" \
                -e's/defined\( \|\t\)*(\( \|\t\)*__FreeBSD__\( \|\t\)*)/defined(__FreeBSD_kernel__)/g ;
                   s/#\( \|\t\)*ifdef\( \|\t\)*__FreeBSD__/#ifdef __FreeBSD_kernel__/g ;
                   s/#\( \|\t\)*ifndef\( \|\t\)*__FreeBSD__/#ifndef __FreeBSD_kernel__/g ;
                   s/__FreeBSD__/${major}/g ;
                   s,#\( \|\t\)*include\( \|\t\)*<sys/device.h>,,g ;
                   s,#\( \|\t\)*include\( \|\t\)*<dev/rndvar.h>,,g ;
                   s,#\( \|\t\)*include\( \|\t\)*<sys/pool.h>,,g ;
                   s,#\( \|\t\)*include\( \|\t\)*<netinet/ip_ipsp.h>,,g ;
                   s,#\( \|\t\)*include\( \|\t\)*\(<\|"\)bpfilter.h\(>\|"\),,g ;
                   s,#\( \|\t\)*include\( \|\t\)*\(<\|"\)pflog.h\(>\|"\),,g' \;

       grep -v ^__FBSDID src/sys/kern/subr_sbuf.c > src/usr.sbin/config/sbuf.c
    '';

  configurePhase =
    '' # Define variables used by the makefiles.
       export MACHINE_ARCH="$(uname -p)"
       export WERROR=
       export MAKE="${pmake}/bin/make"

       # Set /lib/modules/VERSION as module dir.
       sed -i -e "s,^KODIR?=.*,KODIR=\"$out/lib/modules/${version}\",g" src/sys/conf/kern.pre.mk

       # Build the configury stuff.
       cp -afv src/usr.sbin/config config
       ( cd config ; $MAKE )
       export PATH="$PWD/config:$PATH"

       # Configure the kernel
       cp -v "${config}" "src/sys/$(uname -p)/conf/"
       cat "src/sys/$(uname -p)/conf/GENERIC" >> "src/sys/$(uname -p)/conf/$(uname -m).config"
       ln -sfv "$(uname -m).config" "src/sys/$(uname -p)/conf/${configfile}"
       ( cd "src/sys/$(uname -p)/conf" && config "${configfile}" )
    '';


  buildPhase =
    '' ( cd "src/sys/$(uname -p)/compile/${configfile}/" ; $MAKE depend )
       ( cd "src/sys/$(uname -p)/compile/${configfile}/" ; $MAKE )
    '';

  headerInstallPhase =
    '' ensureDir "$out/include"
       find src -type f -name "*.h" -not -regex ".*modules.*" \
                -not -regex ".*sys/$(cpu)/.*" \
                -exec cp -v --parents {} "$out/include" \;
    '';

  installPhase =
    '' ${headerInstallPhase}

       ensureDir "$out/boot"
       ensureDir "$out/lib/modules/${version}"
    '';

}
