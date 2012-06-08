# 
# This convenience include finds if RENDERTEXTURE library is installed
# and set the appropriate libs, incdirs, flags etc. 
##
# -----------------------------------------------------
# USAGE: 
#      just include Use_RENDERTEXTURE.cmake 
#      in your projects CMakeLists.txt
# INCLUDE( ${CMAKE_MODULE_PATH}/Use_RenderTexture.cmake)
##
# ------------------------------------------------------------------
# @author Jan Woetzel <http://www.mip.informatik.uni-kiel.de/~jw> (09/2003)
# ------------------------------------------------------------------

FIND_PACKAGE( RenderTexture )

IF(RENDERTEXTURE_FOUND)
  IF(RENDERTEXTURE_INCLUDE_DIR)
    INCLUDE_DIRECTORIES(${RENDERTEXTURE_INCLUDE_DIR})
  ENDIF(RENDERTEXTURE_INCLUDE_DIR)
  
  IF(RENDERTEXTURE_LINK_DIRECTORIES)
    LINK_DIRECTORIES(${RENDERTEXTURE_LINK_DIRECTORIES})
  ENDIF(RENDERTEXTURE_LINK_DIRECTORIES)

  IF(RENDERTEXTURE_LIBRARIES)
    LINK_LIBRARIES(${RENDERTEXTURE_LIBRARIES})
  ENDIF(RENDERTEXTURE_LIBRARIES)

ELSE(RENDERTEXTURE_FOUND)
  MESSAGE(SEND_ERROR "RENDERTEXTURE not found by Use_RENDERTEXTURE.cmake")
ENDIF(RENDERTEXTURE_FOUND)

