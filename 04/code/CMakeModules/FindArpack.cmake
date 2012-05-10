# -Try to find Arpack
#
#
# The following are set after configuration is done: 
#  Arpack_FOUND
#  Arpack_LIBRARIES

SET(Arpack_POSSIBLE_LIBPATHS
  /usr/lib
  /usr/local/lib
  /usr/lib64
  /usr/local/lib64
)

FIND_LIBRARY(Arpack_LIBRARIES 
  NAMES arpack 
  PATHS ${Arpack_POSSIBLE_LIBPATHS}
)

#MESSAGE("DBG Arpack_LIBBRARIES=${Arpack_LIBRARIES})

IF(NOT Arpack_LIBRARIES)
       MESSAGE(SEND_ERROR "Arpack library not found.")
ENDIF(NOT Arpack_LIBRARIES)

IF(Arpack_LIBRARIES)
	MESSAGE(STATUS "Found Arpack library")
	SET(Arpack_FOUND TRUE)
ELSE(Arpack_LIBRARIES)
	SET(Arpack_FOUND FALSE)
ENDIF(Arpack_LIBRARIES)

MARK_AS_ADVANCED(
  Arpack_LIBRARIES
  Arpack_FOUND
)