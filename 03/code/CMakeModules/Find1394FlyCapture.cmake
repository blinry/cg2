#
# Try to find Pont Grey FlyCapture 1394 firewire camera driver library. 
# available from: www.ptgrey.com
#
# Once run this will define: 
#
# 1394FlyCapture_FOUND
# 1394FlyCapture_INCLUDE_DIR
# 1394FlyCapture_LIBRARIES
# 1394FlyCapture_GUI_LIBRARY . additional library if you want to use teh (MFC) PTG Gui controls.
# 1394FlyCapture_HEADER  This is a hack to allow command completion in MSVS
#
#  (1394FlyCapture_LINK_DIRECTORIES: not yet...)
#
# Jan Woetzel 08/2004.
# www.mip.informatik.uni-kiel.de/~jw
# --------------------------------

IF (NOT WIN32)
  MESSAGE("Find1394CameraCMU.cmake: This library supports only WIN32. skipping.")
  SET(1394FlyCapture_FOUND FALSE)
ENDIF (NOT WIN32)

IF (WIN32)
  FIND_PATH(1394FlyCapture_INCLUDE_DIR PGRFlyCapture.h
    # $ENV{1394FlyCapture_HOME}/include
    "[HKEY_LOCAL_MACHINE\\SOFTWARE\\Point Grey Research, Inc.\\PGRFlyCapture;InstallDir]/include"
    # "$ENV{ProgramFiles}/Point Grey Research/include"
    "$ENV{EXTRA}/include"
    )
  #MESSAGE("DBG 1394FlyCapture_INCLUDE_DIR=${1394FlyCapture_INCLUDE_DIR}")

  FIND_LIBRARY(1394FlyCapture_LIBRARY
    NAMES PGRFlyCapture
    PATHS 
    "[HKEY_LOCAL_MACHINE\\SOFTWARE\\Point Grey Research, Inc.\\PGRFlyCapture;InstallDir]/lib"
    # "$ENV{ProgramFiles}/Point Grey Research/lib"
    "$ENV{EXTRA}/lib"
    )
  #MESSAGE("DBG 1394FlyCapture_LIBRARY=${1394FlyCapture_LIBRARY}")


  FIND_LIBRARY(1394FlyCapture_GUI_LIBRARY
    NAMES pgrflycapturegui
    PATHS 
    "[HKEY_LOCAL_MACHINE\\SOFTWARE\\Point Grey Research, Inc.\\PGRFlyCapture;InstallDir]/lib"
    # "$ENV{ProgramFiles}/Point Grey Research/lib"
    "$ENV{EXTRA}/include"
    )
  #MESSAGE("DBG 1394FlyCapture_GUI_LIBRARY=${1394FlyCapture_GUI_LIBRARY}")

  
  # --------------------------------

  IF(1394FlyCapture_LIBRARY)
    SET(1394FlyCapture_LIBRARIES ${1394FlyCapture_LIBRARY})
  ELSE(1394FlyCapture_LIBRARY)
    MESSAGE(SEND_ERROR "1394FlyCapture library not found.")
  ENDIF(1394FlyCapture_LIBRARY)

  IF(NOT 1394FlyCapture_INCLUDE_DIR)
    MESSAGE(SEND_ERROR "1394FlyCapture include dir not found.")
  ENDIF(NOT 1394FlyCapture_INCLUDE_DIR)

  IF(1394FlyCapture_LIBRARIES AND 1394FlyCapture_INCLUDE_DIR)
    SET(1394FlyCapture_FOUND TRUE)
    
    SET( 1394FlyCapture_HEADER 
      "${1394FlyCapture_INCLUDE_DIR}/PGRFlyCapture.h"
      "${1394FlyCapture_INCLUDE_DIR}/PGRFlyCapturePlus.h"
      "${1394FlyCapture_INCLUDE_DIR}/pgrerror.h"
      "${1394FlyCapture_INCLUDE_DIR}/pgrcameragui.h"
      )
    #MESSAGE("DBG 1394FlyCapture_HEADER=${1394FlyCapture_HEADER}")
    SOURCE_GROUP(FlyCapture1394 FILES ${1394FlyCapture_HEADER})
    
  ELSE(1394FlyCapture_LIBRARIES AND 1394FlyCapture_INCLUDE_DIR)
    SET(1394FlyCapture_FOUND FALSE)
  ENDIF(1394FlyCapture_LIBRARIES AND 1394FlyCapture_INCLUDE_DIR)

  MARK_AS_ADVANCED(
    1394FlyCapture_INCLUDE_DIR
    1394FlyCapture_LIBRARY
    1394FlyCapture_LIBRARIES
    1394FlyCapture_GUI_LIBRARY
    )

ENDIF (WIN32)
