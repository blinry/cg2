# 
# This convenience include finds if 1394CameraCMU library is installed
# and set the appropriate libs, incdirs, flags etc. 
##
# -----------------------------------------------------
# USAGE: 
#      just include Use_1394CameraCMU.cmake 
#      in your projects CMakeLists.txt
# INCLUDE( ${CMAKE_MODULE_PATH}/Use_1394CameraCMU.cmake)
##
# ------------------------------------------------------------------
# @author Jan Woetzel <http://www.mip.informatik.uni-kiel.de/~jw> (02/2004)
# ------------------------------------------------------------------
FIND_PACKAGE( 1394CameraCMU )
IF(1394CameraCMU_FOUND)
  IF(1394CameraCMU_INCLUDE_DIR)
    INCLUDE_DIRECTORIES(${1394CameraCMU_INCLUDE_DIR})
  ENDIF(1394CameraCMU_INCLUDE_DIR)
  
  IF(1394CameraCMU_LINK_DIRECTORIES)
    LINK_DIRECTORIES(${1394CameraCMU_LINK_DIRECTORIES})
  ENDIF(1394CameraCMU_LINK_DIRECTORIES)
  IF(1394CameraCMU_LIBRARIES)
    LINK_LIBRARIES(${1394CameraCMU_LIBRARIES})
  ENDIF(1394CameraCMU_LIBRARIES)
  
  IF(1394CameraCMU_HEADER)
	# create a header source group for CMU header files to allow command completion 
	SOURCE_GROUP(1394CMU FILES ${1394CameraCMU_HEADER})
  ENDIF(1394CameraCMU_HEADER)
  
  
ELSE(1394CameraCMU_FOUND)
  MESSAGE(SEND_ERROR "1394CameraCMU not found by Use_1394CameraCMU.cmake")
ENDIF(1394CameraCMU_FOUND)
