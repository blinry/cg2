# -Try to find SuperLU
#
#
# The following are set after configuration is done: 
#  SuperLU_FOUND
#  SuperLU_LIBRARIES

SET(SuperLU_POSSIBLE_LIBPATHS
  /usr/lib
  /usr/local/lib
  /usr/lib64
  /usr/local/lib64
  /afs/cg.cs.tu-bs.de/lib/linux/c++/superlu/lib
)

FIND_LIBRARY(SuperLU_LIBRARIES 
  NAMES superlu 
  PATHS ${SuperLU_POSSIBLE_LIBPATHS}
)

#MESSAGE("DBG SuperLU_LIBBRARIES=${SuperLU_LIBRARIES})

IF(NOT SuperLU_LIBRARIES)
       MESSAGE(SEND_ERROR "SuperLU library not found.")
ENDIF(NOT SuperLU_LIBRARIES)

IF(SuperLU_LIBRARIES)
	MESSAGE(STATUS "Found SuperLU")
	SET(SuperLU_FOUND TRUE)
ELSE(SuperLU_LIBRARIES)
	SET(SuperLU_FOUND FALSE)
ENDIF(SuperLU_LIBRARIES)

MARK_AS_ADVANCED(
  SuperLU_LIBRARIES
  SuperLU_FOUND
)