#
# Try to find CG from Nvidia
# Once run this will define:
#
# CGGL_FOUND
# CGGL_INCLUDE_DIR
# CGGL_LIBRARIES
#
#  (CGGL_LINK_DIRECTORIES: not yet...)
#
# please keep in mind that cgc(.exe) may be required in path at runtime
#
# Jan Woetzel 2003-2005
# www.mip.informatik.uni-kiel.de/~jw
#
# TODO:
# -add paths from registry for WIN32
#

SET(CGGL_POSSIBLE_INCDIRS
  $ENV{CGGL_DIR}/include
  $ENV{CG_DIR}/include
  $ENV{CG_INC_PATH}
  $ENV{CG_HOME}/include
  "$ENV{ProgramFiles}/NVIDIA Corporation/Cg/include"
  /usr/include
  /usr/local/include
  )

SET(CGGL_POSSIBLE_LIBDIRS
  "$ENV{CG_LIB_PATH}"
  "$ENV{CG_HOME}/lib"
  "$ENV{ProgramFiles}/NVIDIA Corporation/Cg/lib"
  /usr/lib
  /usr/local/lib
  )

FIND_PATH(CG_CORE_INCLUDE_DIR
  NAMES Cg/cg.h
  PATHS ${CGGL_POSSIBLE_INCDIRS} )
#MESSAGE("DBG CG_CORE_INCLUDE_DIR=${CG_CORE_INCLUDE_DIR}")

FIND_PATH(CG_GL_INCLUDE_DIR
  NAMES Cg/cgGL.h
  PATHS ${CGGL_POSSIBLE_INCDIRS} )
#MESSAGE("DBG CG_GL_INCLUDE_DIR=${CG_GL_INCLUDE_DIR}")

FIND_LIBRARY(CG_CORE_LIBRARY
  NAMES Cg cg
  PATHS ${CGGL_POSSIBLE_LIBDIRS} )
#MESSAGE("DBG CG_CORE_LIBRARY=${CG_CORE_LIBRARY}")

FIND_LIBRARY(CG_GL_LIBRARY
  NAMES CgGL cggl
  PATHS ${CGGL_POSSIBLE_LIBDIRS} )
#MESSAGE("DBG CG_GL_LIBRARY=${CG_GL_LIBRARY}")


IF(CG_CORE_LIBRARY AND CG_GL_LIBRARY)
  # OK.
  SET(CGGL_LIBRARIES ${CG_CORE_LIBRARY} ${CG_GL_LIBRARY})
ELSE(CG_CORE_LIBRARY AND CG_GL_LIBRARY)
  IF(NOT CG_CORE_LIBRARY)
    MESSAGE(STATUS "CG core library not found.")
  ENDIF(NOT CG_CORE_LIBRARY)
  IF(NOT CG_GL_LIBRARY)
    MESSAGE(STATUS "CG GL library not found.")
  ENDIF(NOT CG_GL_LIBRARY)
ENDIF(CG_CORE_LIBRARY AND CG_GL_LIBRARY)

IF(CG_CORE_INCLUDE_DIR AND CG_GL_INCLUDE_DIR)

  # OK.
  SET(CGGL_INCLUDE_DIR "${CG_CORE_INCLUDE_DIR}" "${CG_GL_INCLUDE_DIR}" )

ELSE(CG_CORE_INCLUDE_DIR AND CG_GL_INCLUDE_DIR)
  IF(NOT CG_CORE_INCLUDE_DIR)
    MESSAGE(STATUS "CG core include dir not found.")
  ENDIF(NOT CG_CORE_INCLUDE_DIR)
  IF(NOT CG_GL_INCLUDE_DIR)
    MESSAGE(STATUS "CG GL include dir not found.")
  ENDIF(NOT CG_GL_INCLUDE_DIR)
ENDIF(CG_CORE_INCLUDE_DIR AND CG_GL_INCLUDE_DIR)


IF(CGGL_LIBRARIES AND CGGL_INCLUDE_DIR)
  SET(CGGL_FOUND TRUE)
ELSE(CGGL_LIBRARIES AND CGGL_INCLUDE_DIR)
  SET(CGGL_FOUND FALSE)
ENDIF(CGGL_LIBRARIES AND CGGL_INCLUDE_DIR)


MARK_AS_ADVANCED(
  CG_CORE_INCLUDE_DIR
  CG_GL_INCLUDE_DIR
  CG_CORE_LIBRARY
  CG_GL_LIBRARY
  CG_GL_INCLUDE_DIR
  CG_GL_LIBRARY
  CGGL_INCLUDE_DIR
  CGGL_LIBRARIES
  )


#=====================================================================
IF(NOT CGGL_FOUND)
  # make FIND_PACKAGE friendly
  IF(NOT CGGL_FIND_QUIETLY)
    IF(CGGL_FIND_REQUIRED)
      MESSAGE(FATAL_ERROR
        "CGGL required, Please guide cmake with CGGL_DIR.")
    ELSE(CGGL_FIND_REQUIRED)
      MESSAGE(STATUS "ERROR: CGGL was not found. Please guide cmake with CGGL_DIR.")
    ENDIF(CGGL_FIND_REQUIRED)
  ENDIF(NOT CGGL_FIND_QUIETLY)
ENDIF(NOT CGGL_FOUND)

