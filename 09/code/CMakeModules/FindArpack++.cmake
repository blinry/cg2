# -Try to find Arpack++
#
#
# The following are set after configuration is done: 
#  Arpack++_FOUND
#  Arpack++_INCLUDE_DIR


FIND_PATH(Arpack++_INCLUDE_DIR armat.h
  /usr/include/
  /usr/local/include
  /afs/cg.cs.tu-bs.de/lib/linux/c++/arpack++/include
)

#MESSAGE("DBG Arpack++_INCLUDE_DIR=${Arpack++_INCLUDE_DIR}")

IF(NOT Arpack++_INCLUDE_DIR)
       MESSAGE(SEND_ERROR "Arpack++ include dir not found.")
ENDIF(NOT Arpack++_INCLUDE_DIR)

IF(Arpack++_INCLUDE_DIR)
	MESSAGE(STATUS "Using Arpack++ from ${Arpack++_INCLUDE_DIR}")
	SET(Arpack++_FOUND TRUE)
ELSE(Arpackpp_INCLUDE_DIR)
	SET(Arpack++_FOUND FALSE)
ENDIF(Arpack++_INCLUDE_DIR)

MARK_AS_ADVANCED(
  Arpack++_INCLUDE_DIR
  Arpack++_FOUND
)