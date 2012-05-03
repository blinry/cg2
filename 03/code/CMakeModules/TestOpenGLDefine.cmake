##
# test wether OpenGL glext.h needs the define 
# 
# Once run this will define:
# GL_GLEXT_PROTOTYPES             : true if the below define is required
# GL_GLEXT_PROTOTYPES_DEFINITIONS : contains "-DGL_GLEXT_PROTOTYPES" if the define is required
##
# Jan Woetzel 2004/07
# www.mip.informatik.uni-kiel.de/~jw
# --------------------------------

IF (UNIX)
  FIND_PACKAGE(OpenGL)
  
  MESSAGE(STATUS "Testing glext.h with GL_GLEXT_PROTOTYPES define ")
  SET( GL_GLEXT_PROTOTYPES_DEFINITIONS "-DGL_GLEXT_PROTOTYPES")
  TRY_COMPILE(GL_GLEXT_PROTOTYPES
    ${CMAKE_MODULE_PATH}
    ${CMAKE_MODULE_PATH}/TestOpenGLDefine.cpp
    CMAKE_FLAGS 
    -DINCLUDE_DIRECTORIES:STRING=${OPENGL_INCLUDE_DIR} 
    -DCMAKE_CXX_FLAGS:STRING=${GL_GLEXT_PROTOTYPES_DEFINITIONS}
    GL_GLEXT_PROTOTYPES_OUT
    )
  
  IF(GL_GLEXT_PROTOTYPES)
    MESSAGE(STATUS "Testing glext.h with GL_GLEXT_PROTOTYPES define -- works.")
  ELSE(GL_GLEXT_PROTOTYPES)
    #compiled with define - new header files
    MESSAGE(STATUS "Testing glext.h with GL_GLEXT_PROTOTYPES define -- failed.")
    MESSAGE(STATUS "Testing glext.h without defines ")

    SET(GL_GLEXT_PROTOTYPES_DEFINITIONS "")
    # try to compile without definition:
    TRY_COMPILE(GL_GLEXT_PROTOTYPES_NONE
      ${CMAKE_MODULE_PATH}
      ${CMAKE_MODULE_PATH}/TestOpenGLDefine.cpp
      CMAKE_FLAGS 
      -DINCLUDE_DIRECTORIES:STRING=${OPENGL_INCLUDE_DIR} 
      GL_GLEXT_PROTOTYPES_NONE_OUT
      )
    IF(GL_GLEXT_PROTOTYPES_NONE)
      # compiles only without define - old header files
      MESSAGE(STATUS "Testing glext.h without defines -- works")
    ELSE(GL_GLEXT_PROTOTYPES_NONE)
      MESSAGE(STATUS "Testing glext.h without defines -- failed.")
      MESSAGE(SEND_ERROR "TestOpenGLDefine.camke failed. OpenGL test compiled neither with flags nor without. Please fix me.")
    ENDIF(GL_GLEXT_PROTOTYPES_NONE)
  ENDIF(GL_GLEXT_PROTOTYPES)
ENDIF(UNIX)