# 
# This module finds if BIAS is available and determines where the
# include files and libraries are. 
#
# There are two ways this script tries to find a configured BIAS build.
# (1) the 'cmake' way trying to find BIASConfig.cmake script seeting BIAS_CONFIG_CMAKE_SCRIPT
#     You can set an environment variabble BIAS_DIR to select a specific (out-of source) BIAS build
#     or set the cmake varibable directly, e.g. via -DBIAS_DIR:PATH=/path/to/BIASConfig.cmake
# (2) DEPRECATED
#     If the above fails try to find a Unix shell script bias-config setting BIAS_BIASCONFIG_EXECUTABLE
#     This method is depreacted. It's here just for backward compatibility. 
#     You need it just if you want to use a BIAS build that was not compiled with cmake, 
#     but a bias-config shell script is availableand you are using an old "automaked" BIAS build, e.g. from /opt/net/
#
# -------------------------------------------------------
#
# This code sets the following variables:
#
# BIAS_FOUND            = system has BIAS lib
#
# BIAS_LIBRARIES        = full path to the libraries
#                         on Unix/Linux with additional linker flags from "bias-config --libs" 
#                         if (deprecated) shell script is used.
#
# BIAS_CXX_FLAGS        = compiler flags for BIAS, essentially "`bias-config --cxxflags`" if shell script is used
#
# BIAS_INCLUDE_DIR      = where to find headers 
#
# BIAS_LINK_DIRECTORIES = link directories, useful for rpath on Unix
# BIAS_EXE_LINKER_FLAGS = linker flags (may contain rpath on Unix)
#
# BIAS_CONFIG_CMAKE_SCRIPT   = contains used BIASConfig.cmake path if PackageConfig (1) is used.
# BIAS_BIASCONFIG_EXECUTABLE = (DEPRECATED) contains used path of shell script bias-config (2) is used 
#                              (instead of BIASConfig.cmake)
#
# -------------------------------------------------------
#
# typical USAGE in user projects CMakeLists.txt: 
#   FIND_PACKAGE(BIAS)
#   IF (BIAS_FOUND)
#     INCLUDE(${BIAS_USE_FILE})
#   ENDIF (BIAS_FOUND)
#
# - and add the BIAS libraries you really need to each executable or libray ith TARGET_LINK_LIBRARIES
#
# -------------------------------------------------------
#
# author Jan Woetzel <http://www.mip.informatik.uni-kiel.de/~jw>
#
# Strategy: first try to find BIASconfig.cmake and include it emulating the FIND_PACKAGE command.
# This should work on Unix and Windows.
#
# If that fails, try to find bias-config on Unix,
# run it with different arguments, 
# parse output and set variables

# This is the workaround for FIND_PACKAGE which couldn't be used here 
# because CMAKE_MODULE_PATH has higher priority than BIASConfig.cmake path. 
FIND_FILE(BIAS_CONFIG_CMAKE_SCRIPT BIASConfig.cmake 
  ${BIAS_ROOT_DIR}
  $ENV{BIAS_ROOT_DIR}
  ${BIAS_DIR}
  $ENV{BIAS_DIR}
  "${CMAKE_CURRENT_BINARY_DIR}/../BIAS"
  )

IF(BIAS_CONFIG_CMAKE_SCRIPT)
  # OK, PackageConfig found. This should work on Unix and Windows
  INCLUDE(${BIAS_CONFIG_CMAKE_SCRIPT})
  SET(BIAS_FOUND 1)
  MESSAGE(STATUS "FindBIAS.cmake is using ${BIAS_CONFIG_CMAKE_SCRIPT}")

ELSE(BIAS_CONFIG_CMAKE_SCRIPT)
  #
  # try to find a config shell script.
  # This is a workaround if the cmake BIASConfig.cmake way did not work
  #
  
  MESSAGE(SEND_ERROR "FindBIAS.cmake: DEPRECATED: coudl not find BIASConfig-cmake. Using config shell script is deprecated. Please compile BIAS, first and set BIAS_DIR. Ask Jan Woetzel for details.")
  
  IF(WIN32)
    # ########################################################
    ##
    # MS Windows specific:
    ##
    
    #MESSAGE(SEND_ERROR "FindBIAS.cmake: BIAS not (yet) supported on WIN32")
    
  ELSE(WIN32)
    IF(UNIX)
      # ###################################
      # 
      # UNIX/Linux specific:
      # 
      
      SET(BIAS_CONFIG_PREFER_PATH "$ENV{BIAS_HOME}/bin" CACHE STRING "select preferred bias-config binary path")
      
      # (JW) FIND_PROGRAM(CMAKE_BIAS_CONFIG bias-config
      FIND_PROGRAM(BIAS_BIASCONFIG_EXECUTABLE bias-config	${BIAS_CONFIG_PREFER_PATH} 	/usr/bin/	)
      
      #(JW) IF (CMAKE_BIAS_CONFIG) 
      IF (BIAS_BIASCONFIG_EXECUTABLE)
	# OK, found bias-config. 
	#MESSAGE("using ${CMAKE_BIAS_CONFIG}")
	MESSAGE(STATUS "FindBIAS.cmake is using (deprecated) shell script ${BIAS_BIASCONFIG_EXECUTABLE}")
	
	# set CXXFLAGS to be fed into CMAKE_CXX_FLAGS by the user:
	SET(BIAS_CXX_FLAGS "`${CMAKE_BIAS_CONFIG} --cflags`")
	
	# 
	EXEC_PROGRAM(${BIAS_BIASCONFIG_EXECUTABLE}
	  ARGS --prefix
	  OUTPUT_VARIABLE
	  BIAS_INC_OWN )  

	EXEC_PROGRAM(${BIAS_BIASCONFIG_EXECUTABLE}
	  ARGS --incdirs
	  OUTPUT_VARIABLE BIAS_INC_EXT )
	
	SET(BIAS_INCLUDE_DIR ${BIAS_INC_EXT} "${BIAS_INC_OWN}/include" 
	  "${BIAS_INC_OWN}/include/BIAS")

	# set link libraries and link flags
	SET(BIAS_LIBRARIES "`${BIAS_BIASCONFIG_EXECUTABLE} --libs`")
	
	SET(BIAS_EXE_LINKER_FLAGS "`${BIAS_BIASCONFIG_EXECUTABLE} --ldflags`")
	
	# extract link dirs for rpath  
	EXEC_PROGRAM(${BIAS_BIASCONFIG_EXECUTABLE}
	  ARGS --libs
	  OUTPUT_VARIABLE BIAS_CONFIG_LIBS )
	SET(BIAS_CONFIG_LIBS "${BIAS_CONFIG_LIBS}" CACHE STRING INTERNAL)
	
	# split off the link dirs (for rpath)
	# use regular expression to match wildcard equivalent "-L*<endchar>"
	# with <endchar> is a space or a semicolon
	STRING(REGEX MATCHALL "[-][L]([^ ;])+" BIAS_LINK_DIRECTORIES_WITH_PREFIX "${BIAS_CONFIG_LIBS}")
	#      MESSAGE("DBG  BIAS_LINK_DIRECTORIES_WITH_PREFIX=${BIAS_LINK_DIRECTORIES_WITH_PREFIX}")
	
	# remove prefix -L because we need the pure directory for LINK_DIRECTORIES
	# replace -L by ; because the separator seems to be lost otherwise (bug or feature?)
	IF (BIAS_LINK_DIRECTORIES_WITH_PREFIX)
	  STRING(REGEX REPLACE "[-][L]" ";" BIAS_LINK_DIRECTORIES ${BIAS_LINK_DIRECTORIES_WITH_PREFIX} )
	  MESSAGE("DBG  BIAS_LINK_DIRECTORIES=${BIAS_LINK_DIRECTORIES}")	  
	ENDIF (BIAS_LINK_DIRECTORIES_WITH_PREFIX)
	
	# replace space separated string by semicolon separated vector to make 
	# it work with LINK_DIRECTORIES
	SEPARATE_ARGUMENTS(BIAS_LINK_DIRECTORIES)
	MARK_AS_ADVANCED(
	  BIAS_CXX_FLAGS
	  BIAS_LIBRARIES
	  BIAS_LINK_DIRECTORIES
	  BIAS_INCLUDE_DIR
	  BIAS_CONFIG_LIBS	  
	  BIAS_CONFIG_PREFER_PATH
	  )
	
	#ELSE(CMAKE_BIAS_CONFIG)
      ELSE(BIAS_BIASCONFIG_EXECUTABLE)
	MESSAGE(ERROR "neither found BIASConfig.cmake nor bias-config. Either set BIAS_DIR in your environment, use cmake to set this variable, e.g.  -DBIAS_DIR:PATH=/path/to/BIASbuild, or install bias so that bias-config is found using the PATH environment variable. FindBIAS.cmake: bias-config not found. Please set it manually. BIAS_BIASCONFIG_EXECUTABLE=${BIAS_BIASCONFIG_EXECUTABLE} BIAS_DIR=${BIAS_DIR}")
	#ENDIF(CMAKE_BIAS_CONFIG)
      ENDIF(BIAS_BIASCONFIG_EXECUTABLE)
      
    ENDIF(UNIX)
  ENDIF(WIN32)
  
  
  IF(BIAS_LIBRARIES)
    IF(BIAS_INCLUDE_DIR OR BIAS_BIASCONFIG_EXECUTABLE)
      
      SET(BIAS_FOUND 1)
      
    ENDIF(BIAS_INCLUDE_DIR OR BIAS_BIASCONFIG_EXECUTABLE)    
  ENDIF(BIAS_LIBRARIES)
ENDIF(BIAS_CONFIG_CMAKE_SCRIPT)


#=====================================================================
IF(NOT BIAS_FOUND)
  # make FIND_PACKAGE friendly
  IF(NOT BIAS_FIND_QUIETLY)
    IF(BIAS_FIND_REQUIRED)
      MESSAGE(FATAL_ERROR
        "BIAS required, Please guide cmake with BIAS_DIR.")
    ELSE(BIAS_FIND_REQUIRED)
      MESSAGE(STATUS "ERROR: BIAS was not found. Please guide cmake with BIAS_DIR.")
    ENDIF(BIAS_FIND_REQUIRED)
  ENDIF(NOT BIAS_FIND_QUIETLY)
ENDIF(NOT BIAS_FOUND)
