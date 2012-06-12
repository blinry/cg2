# 
# This convenience include finds if 1394FlyCapture library is installed
# and set the appropriate libs, incdirs, flags etc. 
##
# -----------------------------------------------------
# USAGE: 
#      just include Use_1394FlyCaptrure.cmake 
#      in your projects CMakeLists.txt
# INCLUDE( ${CMAKE_MODULE_PATH}/Use_1394FlyCapture.cmake)
##
# ------------------------------------------------------------------
# @author Jan Woetzel <http://www.mip.informatik.uni-kiel.de/~jw> (08/2004)
# ------------------------------------------------------------------
FIND_PACKAGE( 1394FlyCapture )
IF(1394FlyCapture_FOUND)
  IF(1394FlyCapture_INCLUDE_DIR)
    INCLUDE_DIRECTORIES(${1394FlyCapture_INCLUDE_DIR})
  ENDIF(1394FlyCapture_INCLUDE_DIR)
  
  IF(1394FlyCapture_LINK_DIRECTORIES)
    LINK_DIRECTORIES(${1394FlyCapture_LINK_DIRECTORIES})
  ENDIF(1394FlyCapture_LINK_DIRECTORIES)
  
  IF(1394FlyCapture_LIBRARIES)
    #  LINK_LIBRARIES(${1394FlyCapture_LIBRARIES})
    MESSAGE(STATUS "Use_L1394FlyCapture.cmake is not adding LINK_LIBRARIES anymore-add if yoursel fif required")
  ENDIF(1394FlyCapture_LIBRARIES)
  
  IF(1394FlyCapture_HEADER)
	# create a header source group for CMU header files to allow command completion 
	SOURCE_GROUP(1394FlyCapture FILES ${1394FlyCapture_HEADER})
  ENDIF(1394FlyCapture_HEADER)
  
  
ELSE(1394FlyCapture_FOUND)
  MESSAGE(SEND_ERROR "1394FlyCapture not found by Use_1394FlyCapture.cmake")
ENDIF(1394FlyCapture_FOUND)
