{ automoc4, cmake, kde, kdelibs, qt4, strigi, qimageblitz, libdbusmenu_qt
, xorg, soprano, shared_desktop_ontologies, lm_sensors, pciutils, libraw1394
, libusb, libxklavier, perl, python, libqalculate, akonadi, consolekit
}:

kde.package {

  buildInputs =
    [ cmake kdelibs qt4 automoc4 strigi qimageblitz libdbusmenu_qt
      xorg.libxkbfile xorg.libXcomposite xorg.libXScrnSaver xorg.libXtst
      xorg.libXcomposite xorg.libXdamage xorg.libXau xorg.libXdmcp
      xorg.libpthreadstubs
      soprano shared_desktop_ontologies lm_sensors pciutils libraw1394
      libusb python libqalculate akonadi perl consolekit
    ];

  # Workaround for undefined reference to ‘dlsym’ in
  # kwinglutils_funcs.cpp and ‘clock_gettime’ in kdm/backend/dm.c.
  NIX_LDFLAGS = "-ldl -lrt";

  preConfigure =
   ''
     # Fix incorrect path to kde4-config.
     substituteInPlace startkde.cmake --replace '$bindir/kde4-config' ${kdelibs}/bin/kde4-config
   '';

  meta = {
    description = "KDE workspace components such as Plasma, Kwin and System Settings";
    license = "GPLv2";
    kde.name = "kde-workspace";
  };
}
