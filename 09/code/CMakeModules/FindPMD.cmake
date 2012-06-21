# Find PMDTec time of flight camera access include+library
#
# Birger Streckel

FIND_PATH(PMD_INCLUDE_DIR pmdmsdk.h
  ${PMD_ROOT_DIR}
  $ENV{PMD_ROOT_DIR}
  $ENV{PMD_DIR}
  )

FIND_LIBRARY(PMD_LIBRARY 
  NAMES pmdaccess
  PATHS
  ${PMD_ROOT_DIR}
  $ENV{PMD_ROOT_DIR}
  $ENV{PMD_DIR}
  DOC "PMD library"
  )


IF(PMD_INCLUDE_DIR)
  IF(PMD_LIBRARY)
    SET( PMD_FOUND TRUE )
    SET( PMD_LIBRARIES ${PMD_LIBRARY} )
  ENDIF(PMD_LIBRARY)
ENDIF(PMD_INCLUDE_DIR)

