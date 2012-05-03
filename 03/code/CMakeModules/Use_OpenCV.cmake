
# 
# This convenience include finds if OpenCV is installed
# and set the appropriate libs, incdirs, flags etc. 

# @author Jan Woetzel <jw -at- mip.informatik.uni-kiel.de> (05/2005)
##
# -----------------------------------------------------
# USAGE: 
# INCLUDE( ${CMAKE_MODULE_PATH}/Use_OpenCV.cmake)
##
# ... and add the dependecies to your target, e.g.:
##
# ADD_EXECUTABLE blah blah.cpp)
# TARGET_LINL_LIBRARIES(blah ${OPENCV:LIBRARIES})
##
# ------------------------------------------------------------------
# @author Jan Woetzel <http://www.mip.informatik.uni-kiel.de/~jw> (07/2003)
# ------------------------------------------------------------------

FIND_PACKAGE( OpenCV )

IF(OPENCV_FOUND)
  
  IF(OPENCV_LIBRARIES)
    LINK_LIBRARIES(${OPENCV_LIBRARIES})
  ENDIF(OPENCV_LIBRARIES)
  
  IF(OPENCV_INCLUDE_DIR)
    INCLUDE_DIRECTORIES(${OPENCV_INCLUDE_DIR})
  ENDIF(OPENCV_INCLUDE_DIR)

ELSE(OPENCV_FOUND)
  MESSAGE(SEND_ERROR "Use_OpenCV.cmake: OpenCV not found!")
ENDIF(OPENCV_FOUND)
