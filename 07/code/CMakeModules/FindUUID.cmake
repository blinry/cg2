# 
# Try to find uuid (universal unique id) library  
# Once run this will define: 
# 
# UUID_FOUND
# UUID_INCLUDE_DIR
# UUID_LIBRARIES
##
#  (UUID_LINK_DIRECTORIES: not yet...)
##
# Jan Woetzel 07/2004.
# www.mip.informatik.uni-kiel.de/~jw
# --------------------------------

FIND_PATH(UUID_INCLUDE_DIR uuid/uuid.h
  $ENV{UUID_HOME}/include
  /usr/include
  /usr/local/include
)
#MESSAGE("DBG UUID_INCLUDE_DIR=${UUID_INCLUDE_DIR}")  
  
FIND_LIBRARY(UUID_LIBRARY
  NAMES uuid UUID  libuuid.so.2 libuuid.so.1 
  PATHS 
  $ENV{UUID_HOME}/lib
  /usr/lib
  /usr/local/lib
)
#MESSAGE("DBG UUID_LIBRARY=${UUID_LIBRARY}")
  
# --------------------------------

IF(UUID_LIBRARY)
  SET(UUID_LIBRARIES ${UUID_LIBRARY})
ELSE(UUID_LIBRARY)
  MESSAGE(SEND_ERROR "UUID library not found. You may need to install e2fsprogs-devel on Linux.")
ENDIF(UUID_LIBRARY)

IF(NOT UUID_INCLUDE_DIR)
  MESSAGE(SEND_ERROR "UUID include dir not found.")
ENDIF(NOT UUID_INCLUDE_DIR)


IF(UUID_LIBRARIES AND UUID_INCLUDE_DIR)
  SET(UUID_FOUND TRUE)
ELSE(UUID_LIBRARIES AND UUID_INCLUDE_DIR)
  SET(UUID_FOUND FALSE)
ENDIF(UUID_LIBRARIES AND UUID_INCLUDE_DIR)


MARK_AS_ADVANCED(
  UUID_INCLUDE_DIR
  UUID_LIBRARY
  UUID_LIBRARIES
)
