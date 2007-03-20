source $stdenv/setup

if ! test -z ${cross}; then
   export CROSS_COMPILE=${cross}-
   export ARCH=${cross}
fi

preBuild() {
	cp $config .config
}

preBuild=preBuild

genericBuild
