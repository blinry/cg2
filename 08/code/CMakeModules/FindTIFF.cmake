#
# Find the native TIFF includes and library
#
# This module defines
# TIFF_INCLUDE_DIR, where to find tiff.h, etc.
# TIFF_LIBRARIES, the libraries to link against to use TIFF.
# TIFF_FOUND, If false, do not try to use TIFF.

# also defined, but not for general use are
# TIFF_LIBRARY, where to find the TIFF library.


FIND_PATH(TIFF_INCLUDE_DIR tiff.h
    $ENV{TIFF_DIR}
    "[HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\Tiff-3.8.0_is1;Inno Setup: App Path]"
    $ENV{ProgramFiles}/GnuWin32/include
    $ENV{ProgramFiles}/GnuWin32
    /usr/include
    /usr/local/include
)

FIND_LIBRARY(TIFF_LIBRARY 
    NAMES libtiff tiff
    PATHS
    $ENV{TIFF_DIR}
    "[HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\Tiff-3.8.0_is1;Inno Setup: App Path]"
    $ENV{ProgramFiles}/GnuWin32/lib
    $ENV{ProgramFiles}/GnuWin32
    /usr/lib
    /usr/local/lib
    DOC "tiff library"
)


IF(TIFF_INCLUDE_DIR)
  IF(TIFF_LIBRARY)
    SET( TIFF_FOUND TRUE )
    SET( TIFF_LIBRARIES ${TIFF_LIBRARY} )
  ENDIF(TIFF_LIBRARY)
ENDIF(TIFF_INCLUDE_DIR)

