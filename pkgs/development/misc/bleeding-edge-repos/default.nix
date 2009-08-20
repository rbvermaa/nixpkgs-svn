args: 
  with args;
  let inherit (builtins) pathExists hasAttr getAttr head; in
  rec {
  /*
    tries to get source in this order
    1) Local .tar.gz in ${HOME}/managed_repos/dist/name.tar.gz (-> see nixRepositoryManager)
    2) By importing                                           
        pkgs/misc/bleeding-edge-fetch-info/name.nix
        (generated by nixRepositoryManager --publish)
  */ 

  managedRepoDir = getConfig [ "bleedingEdgeRepos" "managedRepoDir" ] (builtins.getEnv "HOME" + "/managed_repos");

  sourceByName = name :
    let fetchinfo = if (hasAttr name fetchInfos) 
          then (getAttr name fetchInfos) { inherit fetchurl; }
          else throw "no bleeding edge source attribute found in bleeding-edge-fetch-infos.nix with name ${name}\n"
                     "run NO_FETCH=1 nix-repository-manager <path to nixpkgs> --update <reponame> to add it automatically";
        localTarGZ = managedRepoDir+"/dist/${ lib.dropPath (head fetchinfo.urls) }"; # hack, dropPath should be implemented as primop
        fetchInfos = import ../../../misc/bleeding-edge-fetch-infos.nix; in
    if (getConfig ["bleedingEdgeRepos" "useLocalRepos"] false && builtins.pathExists localTarGZ)
        then localTarGZ else fetchinfo;

  repos = 
      let kde4support = builtins.listToAttrs (map (n: lib.nameValuePair ("kdesupport_"+n) { type = "svn"; url = "svn://anonsvn.kde.org/home/kde/trunk/kdesupport/${n}"; groups="kdesupport"; })
                          [ "akode" "eigen" "gmm" "qca" "qimageblitz" "soprano" "strigi" "taglib" 
                          "automoc" "akonadi" "cpptoxml" "decibel" "emerge" "phonon" "tapioca_qt" "telepathy_qt"]); in
      # in trunk but not yet supported by nix: akonadi/ automoc/ cpptoxml/ decibel/ emerge/ kdewin-installer/ kdewin32/ phonon/ tapioca-qt/ telepathy-qt/
    {
    # each repository has 
    # a type, url and maybe a tag
    # you can add groups names to update some repositories at once
    # see nix-repository-manager expression in haskellPackages

      nix_repository_manager = { type = "darcs"; url = "http://mawercer.de/~marc/repos/nix-repository-manager"; };

      pywebcvs = { type = "svn"; url = "https://pywebsvcs.svn.sourceforge.net/svnroot/pywebsvcs/trunk"; };

      plugins = { type = "darcs"; url="http://code.haskell.org/~dons/code/hs-plugins/"; groups="haskell"; };

      hg2git = { type = "git"; url="git://repo.or.cz/hg2git.git"; };

      # darcs repositories haskell 
      http =  { type= "darcs"; url="http://darcs.haskell.org/http/"; groups="happs"; };
      syb_with_class =  { type="darcs"; url="http://happs.org/HAppS/syb-with-class"; groups="happs"; };
      happs_data =  { type="darcs"; url=http://happs.org/repos/HAppS-Data; groups="happs"; };
      happs_util =  { type="darcs"; url=http://happs.org/repos/HAppS-Util; groups="happs"; };
      happs_state =  { type="darcs"; url=http://happs.org/repos/HAppS-State; groups="happs"; };
      happs_plugins =  { type="darcs"; url=http://happs.org/repos/HAppS-Plugins; groups="happs"; };
      happs_ixset =  { type="darcs"; url=http://happs.org/repos/HAppS-IxSet; groups="happs"; };
      happs_server =  { type="darcs"; url=http://happs.org/repos/HAppS-Server; groups="happs"; };
      happs_hsp = { type="darcs"; url="http://code.haskell.org/HSP/happs-hsp"; groups="happs haskell hsp"; };
      happs_hsp_template = { type="darcs"; url="http://code.haskell.org/HSP/happs-hsp-template"; groups="happs haskell hsp"; };
      # haskell_src_exts_metaquote = { type="darcs"; url=http://code.haskell.org/~morrow/code/haskell/haskell-src-exts-metaquote; groups="happs haskell hsp"; };
      haskell_src_exts = { type="darcs"; url=http://code.haskell.org/HSP/haskell-src-exts/; groups="happs haskell hsp"; };
      
      hsp = { type="darcs"; url="http://code.haskell.org/HSP/hsp"; groups="happs haskell hsp"; };
      hsp_xml = { type="darcs"; url="http://code.haskell.org/HSP/hsp-xml"; groups="happs haskell hsp"; };
      hspCgi = { type="darcs"; url="http://code.haskell.org/HSP/hsp-cgi"; groups="happs haskell hsp"; };
      hjscript = { type="darcs"; url="http://code.haskell.org/HSP/hjscript"; groups="happs haskell hsp"; };
      hjquery = { type="darcs"; url="http://code.haskell.org/HSP/hjquery"; groups="happs haskell hsp"; };
      hjavascript = { type="darcs"; url="http://code.haskell.org/HSP/hjavascript"; groups="happs haskell hsp"; };
      takusen = { type="darcs"; url=http://darcs.haskell.org/takusen/; };
      cabal = { type="darcs"; url=http://darcs.haskell.org/cabal; };
      haxml = { type="darcs"; url=http://www.cs.york.ac.uk/fp/darcs/HaXml; groups = "pg_haskell"; };
      storableVector = { type="darcs"; url=http://darcs.haskell.org/storablevector/; groups = "haskell"; };

      kdepimlibs = { type="svn"; url="svn://anonsvn.kde.org/home/kde/trunk/KDE/kdepimlibs"; groups = "kde"; };
      kdebase = { type="svn"; url="svn://anonsvn.kde.org/home/kde/trunk/KDE/kdebase"; groups = "kde"; };

      cinelerra =  { type="git"; url="git://git.cinelerra.org/j6t/cinelerra.git"; };
      ctags = { type = "svn"; url = "https://ctags.svn.sourceforge.net/svnroot/ctags/trunk"; };
      autofs = { type="git"; url="http://ftp.riken.go.jp/Linux/kernel.org/scm/linux/storage/autofs/autofs.git"; };

      # git repositories 
      hypertable =  { type="git"; url="git://scm.hypertable.org/pub/repos/hypertable.git"; groups=""; };

      getOptions = { type="darcs"; url="http://repetae.net/john/repos/GetOptions"; groups=""; };
      ghc_syb = { type = "git"; url = "git://github.com/nominolo/ghc-syb.git"; groups="haskell scien"; };
    } // kde4support // getConfig [ "bleedingEdgeRepos" "repos" ] {};
}
