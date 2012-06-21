#
# try to find glut library and include files
#
# GLUT_INCLUDE_DIR, where to find GL/glut.h, etc.
# GLUT_LIBRARIES, the libraries to link against to use GLUT.
# GLUT_FOUND, If false, do not try to use GLUT.

# also defined, but not for general use are
# GLUT_glut_LIBRARY = the full path to the glut library.
# GLUT_Xmu_LIBRARY  = the full path to the Xmu library if available.
# GLUT_Xi_LIBRARY   = the full path to the Xi Library if available.

IF (WIN32)

  IF(CYGWIN)

    FIND_PATH( GLUT_INCLUDE_DIR GL/glut.h
      /usr/include
    )

    FIND_LIBRARY( GLUT_glut_LIBRARY glut32
      ${OPENGL_LIBRARY_DIR}
      /usr/lib
      /usr/lib/w32api
      /usr/local/lib
      /usr/X11R6/lib
    )
    
  ELSE(CYGWIN)
	
	# set from environment variable
	# if not set (Jan Woetzel Feb/2004)
	IF(NOT GLUT_ROOT_PATH)
	  SET(GLUT_ROOT_PATH $ENV{GLUT_ROOT_PATH})
	ENDIF(NOT GLUT_ROOT_PATH)
	
	# added ${GLUT_ROOT_PATH} (Jan Woetzel Feb/2004)	
    FIND_PATH( GLUT_INCLUDE_DIR GL/glut.h
      "${GLUT_ROOT_PATH}/include"
      ${GLUT_ROOT_PATH}
      ${GLUT_DIR}/include
      $ENV{EXTRA}/include
      $ENV{EXTRA}
      c:/source/glut/include
      d:/source/glut/include
      $ENV{ProgramFiles}\\Microsoft\ Visual\ Studio\ .NET\ 2003\\Vc7\\PlatformSDK\\Include\\gl
      DOC "directory where glut header GL/glut.h can be found."
    )
    
	# added glut32 in addition to glut
	# added NAMES PATHS syntax (Jan Woetzel Feb/2004)
    FIND_LIBRARY( GLUT_glut_LIBRARY 
      NAMES glut glut32
      PATHS
      ${GLUT_ROOT_PATH}/Release
      ${GLUT_ROOT_PATH}/Debug
      ${GLUT_ROOT_PATH}/lib
      ${GLUT_ROOT_PATH}
      ${GLUT_DIR}/lib
      ${OPENGL_LIBRARY_DIR}
      $ENV{EXTRA}/lib
      $ENV{EXTRA}
      c:/source/glut/lib
      d:/source/glut/lib
      C:\\Program\ Files\\Microsoft\ Visual\ Studio\ .NET\ 2003\\Vc7\\PlatformSDK\\Lib
      DOC "directory where glut library can be found."
    )
    # MESSAGE("GLUT_ROOT_PATH=${GLUT_ROOT_PATH}")
    # MESSAGE("GLUT_INCLUDE_DIR=${GLUT_INCLUDE_DIR}")
    # MESSAGE("GLUT_glut_LIBRARY=${GLUT_glut_LIBRARY}")
    
  ENDIF(CYGWIN)
  
ELSE (WIN32)

  IF (APPLE)
# These values for Apple could probably do with improvement.
    FIND_PATH( GLUT_INCLUDE_DIR GL/glut.h
      ${OPENGL_LIBRARY_DIR}
    )
    SET(GLUT_glut_LIBRARY "-framework Glut" CACHE STRING "GLUT library for OSX")
  ELSE (APPLE)

    FIND_PATH( GLUT_INCLUDE_DIR GL/glut.h
      /usr/include
      /usr/include/GL
      /usr/local/include
      /usr/openwin/share/include
      /usr/openwin/include
      /usr/X11R6/include
      /usr/include/X11
      /opt/graphics/OpenGL/include
      /opt/graphics/OpenGL/contrib/libglut
    )

    FIND_LIBRARY( GLUT_glut_LIBRARY glut
      /usr/lib
      /usr/local/lib
      /usr/openwin/lib
      /usr/X11R6/lib
    )

    FIND_LIBRARY( GLUT_Xi_LIBRARY Xi
      /usr/lib
      /usr/local/lib
      /usr/openwin/lib
      /usr/X11R6/lib
    )

    FIND_LIBRARY( GLUT_Xmu_LIBRARY Xmu
      /usr/lib
      /usr/local/lib
      /usr/openwin/lib
      /usr/X11R6/lib
    )

  ENDIF (APPLE)

ENDIF (WIN32)

SET( GLUT_FOUND "NO" )
IF(GLUT_INCLUDE_DIR)
  IF(GLUT_glut_LIBRARY)
    # Is -lXi and -lXmu required on all platforms that have it?
    # If not, we need some way to figure out what platform we are on.
    SET( GLUT_LIBRARIES
      ${GLUT_glut_LIBRARY}
      ${GLUT_Xmu_LIBRARY}
      ${GLUT_Xi_LIBRARY} 
    )
    SET( GLUT_FOUND "YES" )

#The following deprecated settings are for backwards compatibility with CMake1.4
    SET (GLUT_LIBRARY ${GLUT_LIBRARIES})
    SET (GLUT_INCLUDE_PATH ${GLUT_INCLUDE_DIR})

  ENDIF(GLUT_glut_LIBRARY)
ENDIF(GLUT_INCLUDE_DIR)

MARK_AS_ADVANCED(
  GLUT_INCLUDE_DIR
  GLUT_glut_LIBRARY
  GLUT_Xmu_LIBRARY
  GLUT_Xi_LIBRARY
)
