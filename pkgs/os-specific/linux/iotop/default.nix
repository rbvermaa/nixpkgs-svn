{ stdenv, fetchurl, buildPythonPackage, pythonPackages }:

buildPythonPackage rec {
  name = "iotop-0.4.1";
  namePrefix = "";

  src = fetchurl {
    url = "http://guichaz.free.fr/iotop/files/${name}.tar.bz2";
    sha256 = "1dfvw3khr2rvqllvs9wad9ca3ld4i7szqf0ibq87rn36ickrf3ll";
  };

  propagatedBuildInputs = [ pythonPackages.curses ];

  doCheck = false;

  #installCommand = "python setup.py install --prefix=\"\$prefix\"";
  
  meta = {
    description = "A tool to find out the processes doing the most IO";
    maintainers = [ stdenv.lib.maintainers.raskin ];
    platforms = stdenv.lib.platforms.linux;
  };
}
