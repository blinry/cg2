# Try to find NVSG - Nvidia Scene Graph SDK
#
# See http://developer.nvidia.com/object/nvsg_home.html
#
# Once run this will define: 
#
# NVSG_FOUND
# NVSG_INCLUDE_DIR
# NVSG_LIBRARIES
# 
# NOTES
# tested with NVSGSDK and 2.1.0.9 and 2.1.1.7  on Windows XP with MSVS .net 2003 7.1
#
# AUTHOR
# Jan Woetzel <http://www.mip.informatik.uni-kiel.de/~jw> (2006)

IF    (NOT WIN32)
  MESSAGE(STATUS "FindNVSG.cmake  is tested with WIN32 MSVC only. ")
ENDIF (NOT WIN32)

SET(POSSIBLE_INCDIRS
  $ENV{NVSG_DIR}/nvsg
  $ENV{NVSG_DIR}
  $ENV{EXTRA}/include
  $ENV{EXTRA}
  $ENV{NVSGSDKHOME}
  $ENV{NVSGSDKHOME}/Inc
  $ENV{NVSGSDKHOME}/Inc/nvsg
  "$ENV{ProgramFiles}/NVIDIA Corporation/NVSGSDK/Inc"
  "$ENV{ProgramFiles}/NVIDIA Corporation/NVSGSDK/Inc/nvsg"
  /usr/local/nvsg-sdk
  /usr/local/nvsg-sdk/inc
  /usr/local/nvsg-sdk/inc/nvsg
  /opt/net/gcc41/nvsg-sdk/inc
  /opt/net/gcc41/nvsg-sdk/inc/nvsg
)
FIND_PATH(NVSG_INCLUDE_DIR_NVSG 
  NAMES nvsg/nvsgapi.h
  PATHS
  ${POSSIBLE_INCDIRS} )
#MESSAGE("DBG NVSG_INCLUDE_DIR_NVSG=${NVSG_INCLUDE_DIR_NVSG}")

FIND_PATH(NVSG_INCLUDE_DIR_WIN64
  NAMES WIN64workarounds.h
  PATHS
  ${POSSIBLE_INCDIRS} )
#MESSAGE("DBG NVSG_INCLUDE_DIR=${NVSG_INCLUDE_DIR_WIN64}")


FIND_LIBRARY(NVSG_LIBRARY_NVSG
  NAMES nvsg
  PATHS 
  $ENV{NVSG_DIR}/lib
  $ENV{NVSG_DIR}
  $ENV{EXTRA}/include
  $ENV{EXTRA}
  $ENV{NVSG_DIR}/Lib
  $ENV{NVSG_DIR}/Lib/Debug
  $ENV{NVSG_DIR}/Lib/Release
  $ENV{NVSGSDKHOME}/lib/x86/win/Debug
  #$ENV{NVSGSDKHOME}/lib/x86/win/Release
  "$ENV{ProgramFiles}/NVIDIA Corporation/NVSGSDK/Lib"
  "$ENV{ProgramFiles}/NVIDIA Corporation/NVSGSDK/Lib/Debug"
  #"$ENV{ProgramFiles}/NVIDIA Corporation/NVSGSDK/Lib/Release"
  "$ENV{ProgramFiles}/NVIDIA Corporation/NVSGSDK/Lib/x86/win/Debug"
  #"$ENV{ProgramFiles}/NVIDIA Corporation/NVSGSDK/Lib/x86/win/Release"
  /usr/local/nvsg/lib
  /usr/local/nvsg-sdk/bin/x86/linux/debug
  /usr/local/nvsg-sdk/bin/x86/linux/release
  /opt/net/gcc41/nvsg-sdk/bin/x86/linux/debug
  /opt/net/gcc41/nvsg-sdk/bin/x86/linux/release
)


 
# --------------------------------

IF(NVSG_LIBRARY_NVSG)
  SET(NVSG_LIBRARIES ${NVSG_LIBRARY_NVSG})
ELSE(NVSG_LIBRARY_NVSG)
  MESSAGE(STATUS "NVSG_LIBRARY_NVSG library not found.")
ENDIF(NVSG_LIBRARY_NVSG)

IF (NVSG_INCLUDE_DIR_NVSG)
  SET(NVSG_INCLUDE_DIR ${NVSG_INCLUDE_DIR_NVSG} )
ENDIF (NVSG_INCLUDE_DIR_NVSG)
IF (NVSG_INCLUDE_DIR_WIN64)
  SET(NVSG_INCLUDE_DIR ${NVSG_INCLUDE_DIR} ${NVSG_INCLUDE_DIR_WIN64} )
ENDIF (NVSG_INCLUDE_DIR_WIN64)


IF(NOT NVSG_INCLUDE_DIR)
  MESSAGE(STATUS "NVSG_INCLUDE_DIR include dir not found.")
ENDIF(NOT NVSG_INCLUDE_DIR)

SET(NVSG_FOUND FALSE)
IF   (NVSG_LIBRARIES AND NVSG_INCLUDE_DIR)
  SET(NVSG_FOUND TRUE)
ENDIF(NVSG_LIBRARIES AND NVSG_INCLUDE_DIR)
  

MARK_AS_ADVANCED(
  NVSG_LIBRARY_NVSG
  NVSG_LIBRARIES
  NVSG_INCLUDE_DIR
  NVSG_INCLUDE_DIR_NVSG
  NVSG_INCLUDE_DIR_WIN64
  NVSG_FOUND
)
