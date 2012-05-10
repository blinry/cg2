#
# Try to find libDC1394 for IEEE1394 camera 
# Once run this will define: 
#
# DC1394_FOUND
# DC1394_INCLUDE_DIR
# DC1394_LIBRARIES
#
# Jan Woetzel
# www.mip.informatik.uni-kiel.de/~jw

MESSAGE("--  looking for DC1394 - if you encounter problems")
MESSAGE("--   download the latest version (2.0.0+)")
MESSAGE("--   and install it to /local/libdc1394_2/")

IF(NOT UNIX)
  # MESSAGE("FindDC1394.cmake: libdc1394 only available for Unix.")
  SET(DC1394_FOUND FALSE)
ELSE(NOT UNIX)
  
  FIND_PATH(DC1394_INCLUDE_DIR dc1394/control.h
    $ENV{DC1394_HOME}/include
    /local/libdc1394_2/include
    /usr/include )
  MESSAGE("DBG DC1394_INCLUDE_DIR=${DC1394_INCLUDE_DIR}")  
  
  FIND_LIBRARY(DC1394_LIBRARY
    NAMES dc1394
    PATHS
    /local/libdc1394_2/lib
    $ENV{DC1394_HOME}/lib
    /usr/lib
    )
  MESSAGE("DBG DC1394_LIBRARY=${DC1394_LIBRARY}")
  
  # --------------------------------
  
  IF(DC1394_LIBRARY)
    SET(DC1394_LIBRARIES ${DC1394_LIBRARY})
  ELSE(DC1394_LIBRARY)
    MESSAGE(STATUS "libdc1394 library not found.")
  ENDIF(DC1394_LIBRARY)
  
  IF(NOT DC1394_INCLUDE_DIR)
    MESSAGE(STATUS "libdc1394 include dir not found.")
  ENDIF(NOT DC1394_INCLUDE_DIR)
  
  IF(DC1394_LIBRARIES AND DC1394_INCLUDE_DIR)
    SET(DC1394_FOUND TRUE)
  ELSE(DC1394_LIBRARIES AND DC1394_INCLUDE_DIR)
    SET(DC1394_FOUND FALSE)
  ENDIF(DC1394_LIBRARIES AND DC1394_INCLUDE_DIR)
  
  MARK_AS_ADVANCED(
    DC1394_INCLUDE_DIR
    DC1394_LIBRARIES
    DC1394_LIBRARY
    )
ENDIF(NOT UNIX)
