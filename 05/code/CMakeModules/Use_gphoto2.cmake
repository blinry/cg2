##
# use GPhoto2 library
##
# Jan Woetzel 01/2003
# www.mip.informatik.uni-kiel.de/~jw 
##

IF(UNIX)

  # gphoto2-config should be in your path
  FIND_PROGRAM(CMAKE_GPHOTO2_CONFIG_EXECUTABLE gphoto2-config)
  
  # binary found ?
  IF(CMAKE_GPHOTO2_CONFIG_EXECUTABLE)
    
    # set compile flags: 
    SET(CMAKE_C_FLAGS "`${CMAKE_GPHOTO2_CONFIG_EXECUTABLE} --cflags`")
    SET(CMAKE_CXX_FLAGS "`${CMAKE_GPHOTO2_CONFIG_EXECUTABLE} --cflags`")

    # set link libraries: 
    LINK_LIBRARIES("`${CMAKE_GPHOTO2_CONFIG_EXECUTABLE} --libs`")

  ELSE(CMAKE_GPHOTO2_CONFIG_EXECUTABLE)
    MESSAGE("gphoto2-config not found!!! (JW)")
  ENDIF(CMAKE_GPHOTO2_CONFIG_EXECUTABLE)


ELSE(UNIX)
  MESSAGE(SEND_ERROR "gphoto2 only for Unix/Linux available!")
ENDIF(UNIX)
