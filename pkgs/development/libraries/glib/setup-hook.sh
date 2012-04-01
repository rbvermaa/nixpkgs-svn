if [ -z "$dontRemoveGtkDocs" ]; then
postFixup="
$postFixup
rm -rvf $out/share/gtk-doc
"
fi
