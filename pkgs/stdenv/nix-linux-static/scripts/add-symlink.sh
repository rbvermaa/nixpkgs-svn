$extra2/bin/chmod u+w $out/include
(cd $out/include && $extra2/bin/ln -s $extra/include/* .) || exit 1

cd $out
$findutils/bin/find . | $findutils/bin/xargs $patchelf --interpreter $out/lib/ld-linux.so.2 --shrink-rpath
