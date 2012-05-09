# 
# This convenience include finds if Cg for OpenGL is installed
# and set the appropriate libs, incdirs, flags etc. 
# 
# -----------------------------------------------------
# USAGE: 
#      just include Use_CGGL.cmake 
#      in your projects CMakeLists.txt
# INCLUDE( ${CMAKE_MODULE_PATH}/Use_CGGL.cmake)
# 
# ------------------------------------------------------------------
# @author Jan Woetzel <http://www.mip.informatik.uni-kiel.de/~jw> (09/2003)
# ------------------------------------------------------------------

FIND_PACKAGE( CGGL )

IF(CGGL_FOUND)

  IF(CGGL_INCLUDE_DIR)
    INCLUDE_DIRECTORIES(${CGGL_INCLUDE_DIR})
    #MESSAGE("CGGL_INCLUDE_DIR = ${CGGL_INCLUDE_DIR})
  ENDIF(CGGL_INCLUDE_DIR)

  IF(CGGL_LINK_DIRECTORIES)
    LINK_DIRECTORIES(${CGGL_LINK_DIRECTORIES})
    #MESSAGE("CGGL_LINK_DIRECTORIES#=${CGGL_LINK_DIRECTORIES}")
  ENDIF(CGGL_LINK_DIRECTORIES)

  IF(CGGL_LIBRARIES)
    LINK_LIBRARIES(${CGGL_LIBRARIES})
    #MESSAGE("CGGL_LIBRARIES=${CGGL_LIBRARIES}")
  ENDIF(CGGL_LIBRARIES)

ELSE(CGGL_FOUND)
  MESSAGE(SEND_ERROR "CGGL not found by Use_CGGL.cmake")
ENDIF(CGGL_FOUND)

