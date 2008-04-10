{ fetchurl, stdenv, curl, openssl, zlib, expat, perl, gettext, emacs, cpio
, asciidoc, texinfo, xmlto, docbook2x, docbook_xsl, docbook_xml_dtd_42
, libxslt, tcl, tk, makeWrapper }:

stdenv.mkDerivation rec {
  name = "git-1.5.4.4";

  src = fetchurl {
    url = "mirror://kernel/software/scm/git/${name}.tar.bz2";
    sha256 = "16dcmkj7dfmr1cy28hi0ipc2qx7dy3knnb77w5bn78hwdfd2dcv9";
  };

  patches = [ ./pwd.patch ./docbook2texi.patch ];

  buildInputs = [curl openssl zlib expat gettext cpio]
    ++ (if emacs != null then [emacs] else [])
    ++ # documentation tools
       [ asciidoc texinfo xmlto docbook2x
         docbook_xsl docbook_xml_dtd_42 libxslt ]
    ++ # Tcl/Tk, for `gitk'
       [ tcl tk makeWrapper ];

  makeFlags="prefix=\${out} PERL_PATH=${perl}/bin/perl SHELL_PATH=${stdenv.shell}";

  postInstall =
   (if emacs != null then
	 ''# Install Emacs mode.
	   echo "installing Emacs mode..."
	   make install -C contrib/emacs prefix="$out"

	   # XXX: There are other things under `contrib' that people might want to
	   # install. ''
       else
         ''echo "NOT installing Emacs mode.  Set \`git.useEmacs' to \`true' in your"
	   echo "\`~/.nixpkgs/config.nix' file to change it." '')
   + ''# Install man pages and Info manual
       make PERL_PATH="${perl}/bin/perl" cmd-list.made install install-info \
         -C Documentation ''

   + ''# Wrap `gitk'
       wrapProgram $out/bin/gitk			\
                   --set TK_LIBRARY "${tk}/lib/tk8.4"	\
                   --prefix PATH : "${tk}/bin" ''

   + ''# Wrap `git-gui'
       wrapProgram $out/bin/git-gui			\
                   --set TK_LIBRARY "${tk}/lib/tk8.4"	\
                   --prefix PATH : "${tk}/bin" ''

   + ''# Wrap `git-clone'
       wrapProgram $out/bin/git-clone			\
                   --prefix PATH : "${cpio}/bin" '';

  meta = {
    license = "GPLv2";
    homepage = http://git.or.cz;
    description = "Git, a popular distributed version control system";

    longDescription = ''
      Git, a popular distributed version control system designed to
      handle very large projects with speed and efficiency.
    '';

  };
}
