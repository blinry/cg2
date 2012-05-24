# 
# Try to find OpenAL library  
# Once run this will define: 
# 
# OPENAL_FOUND
# OPENAL_INCLUDE_DIR
# OPENAL_LIBRARIES
# OPENAL_LINK_DIRECTORIES
##
# 2004-08
# Daniel Grest 
# --------------------------------


FIND_PATH(OPENAL_INCLUDE_DIR al.h
  $ENV{OPENAL_DIR}/include/
  $ENV{OPENAL_DIR}/include/AL
  $ENV{OPENAL_HOME}/include/AL
  /usr/include/AL
  )


# candidates for OpenCV library directories:
SET(OPENAL_POSSIBLE_LIBRARY_PATHS
  $ENV{OPENAL_DIR}/lib
  $ENV{$HOME}/cvs/OpenAL/
  /usr/lib
  /usr/local/lib
  /opt/net/gcc41/OpenAL/lib  
  /opt/net/gcc33/OpenAL/lib
  )
#MESSAGE("DBG (OPENAL_POSSIBLE_LIBRARY_PATHS=${OPENAL_POSSIBLE_LIBRARY_PATHS}")


FIND_LIBRARY(OPENAL_LIBRARY
  NAMES openal
  PATHS ${OPENAL_POSSIBLE_LIBRARY_PATHS}
  )

IF(OPENAL_LIBRARY)
  IF (OPENAL_INCLUDE_DIR)
    # OK - all found
    SET(OPENAL_FOUND TRUE)
    SET(OPENAL_LIBRARIES ${OPENAL_LIBRARY})
    # get the link directory for rpath to be used with LINK_DIRECTORIES: 
    GET_FILENAME_COMPONENT(OPENAL_LINK_DIRECTORIES ${OPENAL_LIBRARY} PATH)
  ELSE  (OPENAL_INCLUDE_DIR)
    MESSAGE("OPENAL_INCLUDE_DIR not found.")
  ENDIF (OPENAL_INCLUDE_DIR)
  
ELSE(OPENAL_LIBRARY)
  MESSAGE("OpenAL_LIBRAY not found.")
ENDIF(OPENAL_LIBRARY)


IF (NOT OPENAL_FOUND)
  MESSAGE("OPENAL library not found. Please search manually or set shell variable OPENAL_HOME.")
ENDIF (NOT OPENAL_FOUND)


MARK_AS_ADVANCED(
  OPENAL_INCLUDE_DIR
  OPENAL_LIBRARIES
  OPENAL_LIBRARY
  )
