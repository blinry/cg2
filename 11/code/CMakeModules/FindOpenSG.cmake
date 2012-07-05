# 
# This module finds OpenSG (see www.opensg.org/) 
# and determines where the
# include files and libraries are. 
# On Unix/Linux it relies on the output of osg-config.
##
# This code sets the following variables:
##
# OPENSG_FOUND       = system has OPENSG lib
##
# OPENSG_LIBRARIES   = full path to the libraries
#    on Unix/Linux with additional linker flags from "osg-config --libs"
# 
# CMAKE_OPENSG_CXX_FLAGS  = Unix compiler flags for OPENSG, essentially "`osg-config --cxxflags`"
##
# OPENSG_INCLUDE_DIR      = where to find headers 
##
# OPENSG_LINK_DIRECTORIES = link directories, useful for rpath on Unix
# OPENSG_EXE_LINKER_FLAGS = rpath on Unix
##
# Options: 
# You can set OPENSG_MODULES *before* calling this script (on Linux)
##
# Evers and Jan Woetzel 2004,2005,2006
# www.mip.informatik.uni-kiel.de/~jw
##

IF(WIN32)
  
  # reuse existing env. var OSGROOT from framework: 
  SET(OSGROOT  "$ENV{OSGROOT}")
  STRING(REGEX REPLACE "[\\]" "/" OSGROOT "${OSGROOT}")
  #MESSAGE("DBG OSGROOT=${OSGROOT}")

  SET (OPENSG_POSSIBLE_ROOT_PATHS
    ${OPENSG_DIR}
    $ENV{OPENSG_DIR}
    ${OSG_DIR}
    $ENV{OSG_DIR}
    ${OPENSG_ROOT}
    $ENV{OPENSG_ROOT}
    ${OSGROOT}
    $ENV{OSGROOT}
    "[HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\OpenSG_is1;Inno Setup: App Path]" # OSG 1.6    
    "$ENV{ProgramFiles}/OpenSG"
    )
  #MESSAGE("DBG OPENSG_POSSIBLE_ROOT_PATHS= ${OPENSG_POSSIBLE_ROOT_PATHS}")
  
  # select just one tree here to avoid mixing different versions: 
  FIND_PATH(OPENSG_ROOT_DIR include/OpenSG/OSGBase.h
    ${OPENSG_POSSIBLE_ROOT_PATHS}
    )
  #MESSAGE("DBG OPENSG_ROOT_DIR= ${OPENSG_ROOT_DIR}")

  IF (OPENSG_ROOT_DIR) 
    SET(OPENSG_DEFINITIONS 
      "/D_OSG_HAVE_CONFIGURED_H_ /DOSG_BUILD_DLL /DOSG_DEBUG /DOSG_WITH_GLUT /DOSG_WITH_GIF /DOSG_WITH_TIF /DOSG_WITH_JPG "
      CACHE STRING  "OpenSG Defines ")
    SET(OPENSG_INCLUDE_DIR "${OPENSG_ROOT_DIR}/include" CACHE PATH "OpenSG include dir(s)")
    SET(OPENSG_LIBRARIES
      # MSVCPRTD.lib MSVCRTD.lib winmm.lib wsock32.lib 
      debug OSGBaseD optimized OSGBase
      debug OSGSystemD optimized OSGSystem 
      debug OSGWindowGLUTD optimized OSGWindowGLUT 
      debug OSGWindowWIN32D optimized OSGWindowWIN32 
      glut32
      glu32 
      opengl32
      #   stlport_vc71
      #   tif32 libjpeg
      )  
    SET(OPENSG_LINK_DIRECTORIES "${OPENSG_ROOT_DIR}/lib" CACHE PATH "OpenSG link directories")
    
    # HACK: add to global definitions
    ADD_DEFINITIONS    (${OPENSG_DEFINITIONS})
    # INCLUDE_DIRECTORIES(${OPENSG_INCLUDE_DIR})
    # LINK_DIRECTORIES   (${OPENSG_LINK_DIRECTORIES})
    # LINK_LIBRARIES     (${OPENSG_LIBRARIES})
    
    SET (OPENSG_FOUND TRUE)
  ENDIF (OPENSG_ROOT_DIR)


ENDIF(WIN32)  

# --------------------------------------------------------------

IF(UNIX) 
  SET(OPENSG_CONFIG_PREFER_PATH "$ENV{OPENSG_HOME}/bin" CACHE STRING "preferred path to OpenSG (osg-config)")
  FIND_PROGRAM(OPENSG_CONFIG osg-config
    ${OPENSG_CONFIG_PREFER_PATH}
    ${OPENSG_DIR}
    $ENV{OPENSG_DIR}
    ${OPENSG_DIR}/bin
    $ENV{OPENSG_DIR}/bin
    /usr/bin/
    /opt/net/gcc41/OpenSG/bin    
    /opt/net/gcc33/OpenSG/bin
    )
  # MESSAGE("DBG OPENSG_CONFIG ${OPENSG_CONFIG}")

  SET(OPENSG_OPT_DEF TRUE)
  IF (CMAKE_BUILD_TYPE MATCHES "Release")
    SET(OPENSG_OPT_DEF TRUE)
  ENDIF (CMAKE_BUILD_TYPE MATCHES "Release")
  
  OPTION(OPENSG_OPT "Use optimized (no-debug) version of OpenSG" 
    ${OPENSG_OPT_DEF})
  MARK_AS_ADVANCED(OPENSG_OPT)
  
  IF (OPENSG_CONFIG) 
    GET_FILENAME_COMPONENT(OSG_BASE_DIR ${OPENSG_CONFIG} PATH)

    IF(OPENSG_OPT)
      FIND_LIBRARY(OPENSG_CONTRIB_LIBRARY
	NAMES OSGContrib
	PATHS "${OSG_BASE_DIR}/../lib/opt"
	"${OPENSG_CONFIG_PREFER_PATH}/../lib/opt"
	)
    ELSE(OPENSG_OPT)
      FIND_LIBRARY(OPENSG_CONTRIB_LIBRARY
	NAMES OSGContrib
	PATHS "${OSG_BASE_DIR}/../lib/dbg"
	"${OPENSG_CONFIG_PREFER_PATH}/../lib/dbg"
	)	
    ENDIF(OPENSG_OPT)

    # OK, found osg-config.
    IF (OPENSG_CONTRIB_LIBRARY)
        SET(OPENSG_MODULES "Base System GLUT Contrib")	
    ELSE (OPENSG_CONTRIB_LIBRARY)
        SET(OPENSG_MODULES "Base System GLUT")
    ENDIF (OPENSG_CONTRIB_LIBRARY)
    MARK_AS_ADVANCED(OPENSG_CONTRIB_LIBRARY)    

    # determine if we want optimized OpenSG using "--opt"
   
    # set CXXFLAGS to be fed into CXX_FLAGS by the user:

    IF (OPENSG_OPT)
      EXEC_PROGRAM(${OPENSG_CONFIG}
      ARGS --opt --cflags ${OPENSG_MODULES}
      OUTPUT_VARIABLE OPENSG_TMP_CXX_FLAGS)
    ELSE (OPENSG_OPT)
      EXEC_PROGRAM(${OPENSG_CONFIG}
      ARGS  --cflags ${OPENSG_MODULES}
      OUTPUT_VARIABLE OPENSG_TMP_CXX_FLAGS)
    ENDIF (OPENSG_OPT)
    # MESSAGE("OPENSG_TMP_CXX_FLAGS: ${OPENSG_TMP_CXX_FLAGS}")
     STRING(REGEX REPLACE "[-][I]([^ ;])+" ""
      OPENSG_CXX_FLAGS 
      "${OPENSG_TMP_CXX_FLAGS}" )

    # set INCLUDE_DIRS to prefix+include
    EXEC_PROGRAM(${OPENSG_CONFIG}
      ARGS --prefix
      OUTPUT_VARIABLE OPENSG_PREFIX)
    SET(OPENSG_INCLUDE_DIR ${OPENSG_PREFIX}/include CACHE STRING INTERNAL)
    
    # set link libraries and link flags
    IF (OPENSG_OPT)
      # MESSAGE("DBG using OPENSG Release opt build")
    EXEC_PROGRAM(${OPENSG_CONFIG}
      ARGS --opt --libs ${OPENSG_MODULES}
      OUTPUT_VARIABLE OPENSG_CONFIG_LIBS )
    ELSE (OPENSG_OPT)
      # MESSAGE("DBG using OPENSG debug build")
    # extract link dirs for rpath  
    EXEC_PROGRAM(${OPENSG_CONFIG}
      ARGS --libs ${OPENSG_MODULES}
      OUTPUT_VARIABLE OPENSG_CONFIG_LIBS )
    ENDIF (OPENSG_OPT)
    
    # MESSAGE("DBG OPENSG_CONFIG_LIBS: ${OPENSG_CONFIG_LIBS}" )

    # use regular expression to match wildcard equivalent "-l*<endchar>"
    # with <endchar> is a space or a semicolon
    STRING(REGEX MATCHALL "[-][l]([^ ;])+" 
      OPENSG_LIBRARIES 
      "${OPENSG_CONFIG_LIBS}" )



    # split off the link dirs (for rpath)
    # use regular expression to match wildcard equivalent "-L*<endchar>"
    # with <endchar> is a space or a semicolon
    STRING(REGEX MATCHALL "[-][L]([^ ;])+" 
      OPENSG_LINK_DIRECTORIES_WITH_PREFIX 
      "${OPENSG_CONFIG_LIBS}" )
    #MESSAGE("DBG  OPENSG_LINK_DIRECTORIES_WITH_PREFIX=${OPENSG_LINK_DIRECTORIES_WITH_PREFIX}")
    
    # remove prefix -L because we need the pure directory for LINK_DIRECTORIES
    
    IF (OPENSG_LINK_DIRECTORIES_WITH_PREFIX)
      STRING(REGEX REPLACE "[-][L]" "" OPENSG_LINK_DIRECTORIES "${OPENSG_LINK_DIRECTORIES_WITH_PREFIX}" )
    ENDIF (OPENSG_LINK_DIRECTORIES_WITH_PREFIX)

    IF (OPENSG_OPT)
      EXEC_PROGRAM(${OPENSG_CONFIG}
	ARGS --opt --lflags ${OPENSG_MODULES}
	OUTPUT_VARIABLE OPENSG_EXE_LINKER_FLAGS)
    ELSE (OPENSG_OPT)
      EXEC_PROGRAM(${OPENSG_CONFIG}
	ARGS --lflags ${OPENSG_MODULES}
	OUTPUT_VARIABLE OPENSG_EXE_LINKER_FLAGS)
    ENDIF (OPENSG_OPT)
    STRING(REGEX MATCH "[-]L.*"  OPENSG_EXE_LINKER_FLAGS
      "${OPENSG_EXE_LINKER_FLAGS}" )      
    STRING(REGEX REPLACE "[-]L" ""  OPENSG_EXE_LINKER_FLAGS
      "${OPENSG_EXE_LINKER_FLAGS}" )      


    SET(OPENSG_EXE_LINKER_FLAGS "-Wl,-rpath,${OPENSG_EXE_LINKER_FLAGS}" )
#    MESSAGE("DBG  OPENSG_LINK_DIRECTORIES=${OPENSG_LINK_DIRECTORIES}")
#    MESSAGE("DBG  OPENSG_EXE_LINKER_FLAGS=${OPENSG_EXE_LINKER_FLAGS}")


  ELSE(OPENSG_CONFIG)
    MESSAGE(STATUS "FindOPENSG.cmake: osg-config not found. Please set it manually. OPENSG_CONFIG=${OPENSG_CONFIG}")
  ENDIF(OPENSG_CONFIG)


  IF(OPENSG_LIBRARIES)
    IF(OPENSG_INCLUDE_DIR OR OPENSG_CXX_FLAGS)
      
      SET(OPENSG_FOUND ON)      
      
    ENDIF(OPENSG_INCLUDE_DIR OR OPENSG_CXX_FLAGS)
  ENDIF(OPENSG_LIBRARIES)



ENDIF(UNIX)
# --------------------------------------------------------------


MARK_AS_ADVANCED(
  OPENSG_ROOT_DIR
  OPENSG_CXX_FLAGS
  OPENSG_INCLUDE_DIR
  OPENSG_LIBRARIES
  OPENSG_LINK_DIRECTORIES
  OPENSG_CONFIG
  OPENSG_CONFIG_PREFER_PATH
  OPENSG_EXE_LINKER_FLAGS
  )

