# 
# Try to find DV  library  
# (see www.fftw.org)
# Once run this will define: 
# 
# DV_FOUND
# DV_INCLUDE_DIR 
# DV_LIBRARIES
# DV_LINK_DIRECTORIES
#
# Friso and Jan Woetzel 05/2004
# www.mip.informatik.uni-kiel.de
# --------------------------------

 FIND_PATH(DV_INCLUDE_DIR dv.h
   ${DV_HOME}/include/libdv
   $ENV{DV_HOME}/include/libdv
   /usr/include/libdv
   /usr/local/include/libdv
 )
MESSAGE("DBG DV_INCLUDE_DIR=${DV_INCLUDE_DIR}")  
  
FIND_LIBRARY(DV_LIBRARIES
  NAMES dv
  PATHS 
  ${DV_HOME}/lib
  $ENV{DV_HOME}/lib
  /usr/lib
  /usr/local/lib
  )
MESSAGE("DBG DV_LIBRARIES=${DV_LIBRARIES}")

# --------------------------------

IF(DV_LIBRARIES)
  IF (DV_INCLUDE_DIR)

    # OK, found all we need
    SET(DV_FOUND TRUE)
    GET_FILENAME_COMPONENT(DV_LINK_DIRECTORIES ${DV_LIBRARIES} PATH)
    
  ELSE (DV_INCLUDE_DIR)
    MESSAGE("DV include dir not found. Set DV_HOME to find it.")
  ENDIF(DV_INCLUDE_DIR)
ELSE(DV_LIBRARIES)
  MESSAGE("DV lib not found. Set DV_HOME to find it.")
ENDIF(DV_LIBRARIES)


MARK_AS_ADVANCED(
  DV_INCLUDE_DIR
  DV_LIBRARIES
  DV_LINK_DIRECTORIES
)
