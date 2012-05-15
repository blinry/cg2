# 
# This module finds if MIP is available and determines where the
# include files and libraries are. 
# On Unix/Linux it relies on the output of mip-config.
# This code sets the following variables:
#
#
#
# MIP_FOUND            = system has MIP lib
#
# MIP_LIBRARIES        = full path to the libraries
#                         on Unix/Linux with additional linker flags from "mip-config --libs"
# 
# CMAKE_MIP_CXX_FLAGS  = Unix compiler flags for MIP, essentially "`mip-config --cxxflags`"
#
# MIP_INCLUDE_DIR      = where to find headers "wx/wx.h" "wx/setup.h"
#
# MIP_LINK_DIRECTORIES = link directories, useful for rpath on Unix
# MIP_EXE_LINKER_FLAGS = rpath on Unix#
#
# author Jan Woetzel <http://www.mip.informatik.uni-kiel.de/~jw>
#
# typical USAGE in user projects CMakeLists.txt: 
#   FIND_PACKAGE(BIAS)
#   IF (BIAS_FOUND)
#     INCLUDE(${BIAS_USE_FILE})
#   ENDIF (BIAS_FOUND)
#
# Jan Woetzel
# www.mip.informatik.uni-kiel.de/~jw


FIND_FILE(MIP_CONFIG_CMAKE_SCRIPT MIPConfig.cmake 
  ${MIP_ROOT_DIR}
  $ENV{MIP_ROOT_DIR}
  ${MIP_DIR}
  $ENV{MIP_DIR}
  "${CMAKE_CURRENT_BINARY_DIR}/../MIP"
  )

IF(MIP_CONFIG_CMAKE_SCRIPT)
  #  MESSAGE("Found: ${MIP_CONFIG_CMAKE_SCRIPT}")
  INCLUDE(${MIP_CONFIG_CMAKE_SCRIPT})
  SET(MIP_FOUND 1)
  MESSAGE(STATUS "FindMIP is Using ${MIP_CONFIG_CMAKE_SCRIPT}")

ELSE(MIP_CONFIG_CMAKE_SCRIPT)
  
  IF(WIN32)
    # ###################################
    #
    # MS Windows specific:
    #
    MESSAGE(SEND_ERROR "FindMIP.cmake: MIP not (yet) supported on WIN32")
    
  ELSE(WIN32)
    IF(UNIX)
      
      # ######################################################################
      # 
      # UNIX/Linux specific:
      # 
      
      SET(MIP_CONFIG_PREFER_PATH "$ENV{MIP_HOME}/bin" CACHE STRING "select preferred mip-config binary path")
      SET(MIP_CONFIG_POSSIBLE_PATHS
	${MIP_CONFIG_PREFER_PATH}
	$ENV{$MIP_HOME}/bin
	$ENV{$BIAS_HOME}/bin
	/usr/bin/ )
      
      FIND_PROGRAM(CMAKE_MIP_CONFIG mip-config
	${MIP_CONFIG_POSSIBLE_PATHS} )
      
      IF (CMAKE_MIP_CONFIG) 
	# OK, found mip-config. 
	MESSAGE("using ${CMAKE_MIP_CONFIG}")

	# set CXXFLAGS to be fed into CMAKE_CXX_FLAGS by the user:
	SET(MIP_CXX_FLAGS "`${CMAKE_MIP_CONFIG} --cflags`")
	
	SET(MIP_EXE_LINKER_FLAGS "`${CMAKE_MIP_CONFIG} --ldflags`")
	
	# set link libraries and link flags
	SET(MIP_LIBRARIES "`${CMAKE_MIP_CONFIG} --libs`")
	
	# extract link dirs for rpath  
	EXEC_PROGRAM(${CMAKE_MIP_CONFIG}
	  ARGS --libs
	  OUTPUT_VARIABLE MIP_CONFIG_LIBS )
	SET(MIP_CONFIG_LIBS "${MIP_CONFIG_LIBS}" CACHE STRING INTERNAL)
	# split off the link dirs (for rpath)
	# use regular expression to match wildcard equivalent "-L*<endchar>"
	# with <endchar> is a space or a semicolon
	STRING(REGEX MATCHALL "[-][L]([^ ;])+" MIP_LINK_DIRECTORIES_WITH_PREFIX "${MIP_CONFIG_LIBS}")
	#MESSAGE("DBG  MIP_LINK_DIRECTORIES_WITH_PREFIX=${MIP_LINK_DIRECTORIES_WITH_PREFIX}")
	
	# remove prefix -L because we need the pure directory for LINK_DIRECTORIES
	# replace -L by ; because the separator seems to be lost otherwise (bug or feature?)
	IF (MIP_LINK_DIRECTORIES_WITH_PREFIX)
	  STRING(REGEX REPLACE "[-][L]" ";" MIP_LINK_DIRECTORIES ${MIP_LINK_DIRECTORIES_WITH_PREFIX} )
	  #MESSAGE("DBG  MIP_LINK_DIRECTORIES=${MIP_LINK_DIRECTORIES}")
	ENDIF (MIP_LINK_DIRECTORIES_WITH_PREFIX)
	
	# replace space separated string by semicolon separated vector to make it work with LINK_DIRECTORIES
	SEPARATE_ARGUMENTS(MIP_LINK_DIRECTORIES)


	EXEC_PROGRAM(${CMAKE_MIP_CONFIG}
	  ARGS --incdirs
	  OUTPUT_VARIABLE MIP_CONFIG_INCDIRS )

	SET(MIP_INCLUDE_DIR "${MIP_CONFIG_INCDIRS}" CACHE STRING INTERNAL)
	MESSAGE("New coll incs: ${MIP_INCLUDE_DIR}")

	
	MARK_AS_ADVANCED(
	  MIP_CXX_FLAGS
	  MIP_INCLUDE_DIR
	  MIP_LIBRARIES
	  MIP_LINK_DIRECTORIES
	  )
	
      ELSE(CMAKE_MIP_CONFIG)
	MESSAGE(ERROR "neither found MIPConfig.cmake nor mip-config. Either set MIP_DIR in your environment, use cmake to set this variable -DMIP_DIR:PATH=/path/to/mip or install mip so that mip-config is found using the PATH environment variable. FindMIP.cmake: mip-config not found. Please set it manually. CMAKE_MIP_CONFIG=${CMAKE_MIP_CONFIG} MIP_DIR=${MIP_DIR}")
      ENDIF(CMAKE_MIP_CONFIG)
      #MESSAGE("MIP_LINKDIRECTORY: ${MIP_LINK_DIRECTORIES}")
    ENDIF(UNIX)
  ENDIF(WIN32)
  
  
ENDIF(MIP_CONFIG_CMAKE_SCRIPT)


IF(MIP_LIBRARIES)
  IF(MIP_INCLUDE_DIR OR MIP_CXX_FLAGS)
    
    SET(MIP_FOUND 1)
    
  ENDIF(MIP_INCLUDE_DIR OR MIP_CXX_FLAGS)
ENDIF(MIP_LIBRARIES)
