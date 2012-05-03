# -Try to find Lapack library  
# Once run this will define: 
# 
# BLAS_FOUND
# BLAS_LIBRARIES
#
# Friso and  Jan Woetzel 2004
# www.mip.informatik.uni-kiel.de/~jw
# --------------------------------

FIND_LIBRARY(BLAS_LIBRARY
  NAMES BLAS blas
  PATHS 
  ${BLAS_DIR}
  ${BLAS_DIR}/lib
  $ENV{BLAS_DIR}
  $ENV{BLAS_DIR}/lib
  ${BLAS_HOME}
  ${BLAS_HOME}/lib
  $ENV{BLAS_HOME}
  $ENV{BLAS_HOME}/lib
  ${LAPACK_DIR}
  ${LAPACK_DIR}/lib
  $ENV{LAPACK_DIR}
  $ENV{LAPACK_DIR}/lib
  ${LAPACK_HOME}
  $ENV{LAPACK_HOME}
  $ENV{LAPACK_HOME}/lib
  $ENV{EXTRA}/lib
  $ENV{EXTRA}  
  /usr/lib
  /usr/lib/atlas # ATLAS - Automatically Tuned Linear Algebra Software
  /usr/local/lib
  )

IF (WIN32)
  # no header on Unix because lapack is an extern fortran library, there (JW)
  FIND_PATH(BLAS_INCLUDE_DIRECTORIES Blas.h
    ${BLAS_DIR}
    ${BLAS_DIR}/include
    $ENV{BLAS_DIR}
    $ENV{BLAS_DIR}/include
    ${BLAS_HOME}
    ${BLAS_HOME}/include
    $ENV{BLAS_HOME}
    $ENV{BLAS_HOME}/include
    ${LAPACK_HOME}
    $ENV{LAPACK_HOME}
    $ENV{LAPACK_HOME}/include
    $ENV{EXTRA}/include
    $ENV{EXTRA}
    )
ENDIF (WIN32)
#MESSAGE("DBG BLAS_INCLUDE_DIRECTORIES=${BLAS_INCLUDE_DIRECTORIES}")

IF(UNIX AND BLAS_LIBRARY)
  SET(BLAS_LIBRARIES ${BLAS_LIBRARY})
  SET(BLAS_FOUND TRUE)
ELSE(UNIX AND BLAS_LIBRARY)
  # JW do not message, here.
  # MESSAGE("BLAS library not found.")
ENDIF(UNIX AND BLAS_LIBRARY)

IF(WIN32 AND BLAS_LIBRARY AND BLAS_INCLUDE_DIRECTORIES)
  SET(BLAS_LIBRARIES ${BLAS_LIBRARY})
  SET(BLAS_FOUND TRUE)
ENDIF(WIN32 AND BLAS_LIBRARY AND BLAS_INCLUDE_DIRECTORIES)

MARK_AS_ADVANCED(
  BLAS_INCLUDE_DIR
  BLAS_LIBRARY
  BLAS_LIBRARIES
  BLAS_INCLUDE_DIRECTORIES
  )

#=====================================================================
IF(NOT BLAS_FOUND)
  # make FIND_PACKAGE friendly
  IF(NOT BLAS_FIND_QUIETLY)
    IF(BLAS_FIND_REQUIRED)
      MESSAGE(FATAL_ERROR
        "BLAS required, Please guide cmake with BLAS_DIR.")
    ELSE(BLAS_FIND_REQUIRED)
      MESSAGE(STATUS "ERROR: BLAS was not found. Please guide cmake with BLAS_DIR.")
    ENDIF(BLAS_FIND_REQUIRED)
  ENDIF(NOT BLAS_FIND_QUIETLY)
ENDIF(NOT BLAS_FOUND)
