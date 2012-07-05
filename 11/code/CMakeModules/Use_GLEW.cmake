# 
# This convenience include finds if GLEW library is installed
# and set the appropriate libs, incdirs, flags etc. 
##
# -----------------------------------------------------
# USAGE: 
#      just include Use_GLEW.cmake 
#      in your projects CMakeLists.txt
# INCLUDE( ${CMAKE_ROOT}/Modules/Use_GLEW.cmake)
##
# ------------------------------------------------------------------
# @author Jan Woetzel <http://www.mip.informatik.uni-kiel.de/~jw> (09/2003)
# ------------------------------------------------------------------
FIND_PACKAGE( GLEW )
IF(GLEW_FOUND)
  IF(GLEW_INCLUDE_DIR)
    INCLUDE_DIRECTORIES(${GLEW_INCLUDE_DIR})
    # MESSAGE("Use_GLEW.cmake: GLEW_INCLUDE_DIR=${GLEW_INCLUDE_DIR}")
  ENDIF(GLEW_INCLUDE_DIR)
  IF(GLEW_LINK_DIRECTORIES)
    LINK_DIRECTORIES(${GLEW_LINK_DIRECTORIES})
    # MESSAGE("Use_GLEW.cmake: GLEW_LINK_DIRECTORIES=${GLEW_LINK_DIRECTORIES}")
  ENDIF(GLEW_LINK_DIRECTORIES)
  IF(GLEW_LIBRARIES)
    LINK_LIBRARIES(${GLEW_LIBRARIES})
    # MESSAGE("Use_GLEW.cmake: GLEW_LIBRARIES=${GLEW_LIBRARIES}")
  ENDIF(GLEW_LIBRARIES)
  IF(GLEW_DEFINITIONS)
    ADD_DEFINITIONS(${GLEW_DEFINITIONS})
   # MESSAGE("Use_GLEW.cmake: GLEW_DEFINITIONS=${GLEW_DEFINITIONS}")
  ENDIF(GLEW_DEFINITIONS)
	
ELSE(GLEW_FOUND)
  MESSAGE(SEND_ERROR "GLEW not found by Use_GLEW.cmake")
ENDIF(GLEW_FOUND)

