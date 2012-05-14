# 
# This convenience include finds if MIP is installed
# and set the appropriate libs, flags etc. 
# does *not* add libraries (add them by hand or use Use_MIP.cmake) !!!
##
# ------------------------------------------------------------------
# @author Jan Woetzel <http://www.mip.informatik.uni-kiel.de/~jw> (09/2003)
# ------------------------------------------------------------------

FIND_PACKAGE( MIP )

IF(MIP_FOUND)
  
  # other libs should enable their mip-dependant code:
  ADD_DEFINITIONS(-DHAVE_MIP)
  
  IF(MIP_INCLUDE_DIR)
    INCLUDE_DIRECTORIES(${MIP_INCLUDE_DIR})
  ENDIF(MIP_INCLUDE_DIR)
  
  IF(MIP_LINK_DIRECTORIES)
    LINK_DIRECTORIES(${MIP_LINK_DIRECTORIES})
  ENDIF(MIP_LINK_DIRECTORIES)
  
  # solve library dependencies by hand (for faster compilation and avoid unused deps)
  #  IF(MIP_LIBRARIES)#
  #    LINK_LIBRARIES(${MIP_LIBRARIES})
  #  ENDIF(MIP_LIBRARIES)
  
  IF (CMAKE_MIP_CXX_FLAGS)
    SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${CMAKE_MIP_CXX_FLAGS}")
    SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${CMAKE_MIP_CXX_FLAGS}")
  ENDIF(CMAKE_MIP_CXX_FLAGS)
  
ELSE(MIP_FOUND)
  MESSAGE(SEND_ERROR "MIP not found by Use_MIP_nolibs.cmake")
  
ENDIF(MIP_FOUND)
