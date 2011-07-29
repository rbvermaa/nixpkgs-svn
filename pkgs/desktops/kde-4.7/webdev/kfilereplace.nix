{ kde, cmake, kdelibs, qt4, automoc4, phonon, libxml2, libxslt }:

kde.package {
  buildInputs = [ cmake kdelibs qt4 automoc4 phonon libxml2 libxslt ];

  meta = {
    description = "Batch search and replace tool";
    homepage = http://www.kdewebdev.org;
    kde = {
      name = "kfilereplace";
      module = "kdewebdev";
      version = "0.1";
      versionFile = "main.cpp";
    };
  };
}
