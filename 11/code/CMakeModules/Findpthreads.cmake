##
# Try to find pthreads library
# useful for WIN32
# Once run this will define:
##
# PTHREADS_FOUND
# PTHREADS_LINK_DIRECTORIES
# PTHREADS_LIBRARIES
# PTHREADS_INCLUDE_DIR
##
# 2004/12 Birger Streckel
# 2005 complete rewrite Jan Woetzel
# --------------------------------


SET(PTHREADS_POSSIBLE_INCLUDE_PATHS
  ${PTHREADS_DIR}
  $ENV{PTHREADS_DIR}
  $ENV{PTHREADS_DIR}/include
  ${PTHREADS_HOME}
  $ENV{PTHREADS_HOME}
  $ENV{PTHREADS_HOME}/include
  $ENV{EXTRA}/include
  $ENV{EXTRA}
  )

SET(PTHREADS_POSSIBLE_LIBRARY_PATHS
  ${PTHREADS_DIR}
  $ENV{PTHREADS_DIR}
  $ENV{PTHREADS_DIR}/lib
  ${PTHREADS_HOME}
  $ENV{PTHREADS_HOME}
  $ENV{PTHREADS_HOME}/lib
  $ENV{EXTRA}/lib
  $ENV{EXTRA}
  )


FIND_PATH(PTHREADS_INCLUDE_DIR pthread.h
  ${PTHREADS_POSSIBLE_INCLUDE_PATHS} )
#MESSAGE("DBG PTHREADS_INCLUDE_DIR=${PTHREADS_INCLUDE_DIR}")

IF (UNIX)
  FIND_LIBRARY(PTHREADS_LIBRARIES
    NAMES pthread pthreads
    PATHS ${PTHREADS_POSSIBLE_LIBRARY_PATHS} )
  # assume we always have pthread on Linux
  # no matter if found
  IF    (NOT PTHREADS_LIBRARIES)
    SET(PTHREADS_LIBRARIES "pthread")
  ENDIF (NOT PTHREADS_LIBRARIES)
  SET(PTHREADS_FOUND TRUE)
ENDIF(UNIX)
IF(WIN32)
  FIND_LIBRARY(PTHREADS_VC1_LIBRARY
    NAMES pthreadVC1
    PATHS ${PTHREADS_POSSIBLE_LIBRARY_PATHS} )
  FIND_LIBRARY(PTHREADS_VCSE1_LIBRARY
    NAMES pthreadVSE1
    PATHS ${PTHREADS_POSSIBLE_LIBRARY_PATHS} )
ENDIF(WIN32)


IF    (PTHREADS_INCLUDE_DIR)
  IF    (UNIX AND PTHREADS_LIBRARIES)

    SET(PTHREADS_FOUND TRUE)
    GET_FILENAME_COMPONENT(PTHREADS_LINK_DIRECTORIES ${PTHREADS_LIBRARIES} PATH)

  ELSE (UNIX AND PTHREADS_LIBRARIES)
    IF   (WIN32 AND PTHREADS_VC1_LIBRARY AND PTHREADS_VCSE1_LIBRARY)

      SET(PTHREADS_FOUND TRUE)
      SET(PTHREADS_LIBRARIES ${PTHREADS_VC1_LIBRARY} ${PTHREADS_VCSE1_LIBRARY})
      GET_FILENAME_COMPONENT(PTHREADS_LINK_DIRECTORIES ${PTHREADS_VC1_LIBRARY} PATH)

    ELSE (WIN32 AND PTHREADS_VC1_LIBRARY AND PTHREADS_VCSE1_LIBRARY)
      MESSAGE("PTHREADS library not found. Please set PTHREADS_DIR to help finding it.")
    ENDIF(WIN32 AND PTHREADS_VC1_LIBRARY AND PTHREADS_VCSE1_LIBRARY)
  ENDIF (UNIX AND PTHREADS_LIBRARIES)
ELSE(PTHREADS_INCLUDE_DIR)
  MESSAGE("PTHREADS include dir not found. Please set PTHREADS_DIR to help finding it.")
ENDIF (PTHREADS_INCLUDE_DIR)


MARK_AS_ADVANCED(
  PTHREADS_INCLUDE_DIR
  PTHREADS_LIBRARIES
  PTHREADS_VC1_LIBRARY
  PTHREADS_VCSE1_LIBRARY
  )
