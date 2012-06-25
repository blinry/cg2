# defines PNG_FOUND
#         PNG_LIBRARIES
#         PNG_LIBRARY
#         PNG_INCLUDE_DIR

FIND_PATH(PNG_INCLUDE_DIR png.h
  /usr/include
  /usr/local/include
)

FIND_LIBRARY(PNG_LIBRARY 
  NAMES libpng png
  PATHS /usr/lib /usr/local/lib /usr/lib64 /usr/local/lib64
)

IF(PNG_INCLUDE_DIR)
  IF(PNG_LIBRARY)
    SET(PNG_FOUND TRUE)
    SET(PNG_LIBRARIES ${PNG_LIBRARY} )
    MESSAGE(STATUS "Found png library")
  ENDIF(PNG_LIBRARY)
ENDIF(PNG_INCLUDE_DIR)