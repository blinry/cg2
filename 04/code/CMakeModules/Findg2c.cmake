# -Try to find g2c
#
#
# The following are set after configuration is done: 
#  g2c_FOUND
#  g2c_LIBRARIES

SET(g2c_POSSIBLE_LIBPATHS
  /usr/lib
  /usr/local/lib
  /usr/lib64
  /usr/local/lib64
)

FIND_LIBRARY(g2c_LIBRARIES 
  NAMES  g2c
  PATHS ${g2c_POSSIBLE_LIBPATHS}
)
#MESSAGE("DBG g2c_LIBBRARIES=${g2c_LIBRARIES})

IF(NOT g2c_LIBRARIES)
       MESSAGE(SEND_ERROR "g2c library not found.")
ENDIF(NOT g2c_LIBRARIES)

IF(g2c_LIBRARIES)
	MESSAGE(STATUS "Found g2c library")
	SET(g2c_FOUND TRUE)
ELSE(g2c_LIBRARIES)
	SET(g2c_FOUND FALSE)
ENDIF(g2c_LIBRARIES)

MARK_AS_ADVANCED(
  g2c_LIBRARIES
  g2c_FOUND
)