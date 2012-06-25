# 
# This module finds if S2DT is available and determines where the
# include files and libraries are. 
##
# There are two ways this script tries to find a configured S2DT build.
# (1) the 'cmake' way trying to find S2DTConfig.cmake script seeting S2DT_CONFIG_CMAKE_SCRIPT
#     You can set an environment variabble S2DT_DIR to select a specific (out-of source) S2DT build
#     or set the cmake varibable directly, e.g. via -DS2DT_DIR:PATH=/path/to/S2DTConfig.cmake
##
# -------------------------------------------------------
##
# This code sets the following variables:
##
# S2DT_FOUND            = system has S2DT lib
##
# S2DT_LIBRARIES        = full path to the libraries
#                         on Unix/Linux with additional linker flags 
##
# S2DT_CXX_FLAGS        = compiler flags for S2DT
##
# S2DT_INCLUDE_DIR      = where to find headers 
##
# S2DT_LINK_DIRECTORIES = link directories, useful for rpath on Unix
# S2DT_EXE_LINKER_FLAGS = linker flags (may contain rpath on Unix)
##
# S2DT_CONFIG_CMAKE_SCRIPT   = contains used S2DTConfig.cmake path if PackageConfig (1) is used.
##
# -------------------------------------------------------
##
# typical USAGE in user projects CMakeLists.txt: 
#   FIND_PACKAGE(S2DT)
#   IF (S2DT_FOUND)
#     INCLUDE(${S2DT_USE_FILE})
#   ENDIF (S2DT_FOUND)
##
# - and add the S2DT libraries you really need to each executable or libray ith TARGET_LINK_LIBRARIES
##
# -------------------------------------------------------
##
# author Felix Woelk 07/2005
# www.mip.informatik.uni-kiel.de
##
# Try to find and include S2DTconfig.cmake using the FIND_PACKAGE command.
# This should work on Unix and Windows.
##

# This is the workaround for FIND_PACKAGE which couldn't be used here 
# because CMAKE_MODULE_PATH has higher priority than S2DTConfig.cmake path. 
FIND_FILE(S2DT_CONFIG_CMAKE_SCRIPT S2DTConfig.cmake 
  ${S2DT_DIR}
  $ENV{S2DT_DIR}
  "${CMAKE_CURRENT_BINARY_DIR}/../Scan2DTracking"
  )

IF(S2DT_CONFIG_CMAKE_SCRIPT)
  # OK, PackageConfig found. This should work on Unix and Windows
  INCLUDE(${S2DT_CONFIG_CMAKE_SCRIPT})
  SET(S2DT_FOUND 1)
  MESSAGE(STATUS "FindS2DT.cmake is using ${S2DT_CONFIG_CMAKE_SCRIPT}")

ELSE(S2DT_CONFIG_CMAKE_SCRIPT)
  MESSAGE(SEND_ERROR " S2DT_CONFIG_CMAKE_SCRIPT not found. by FindS2DT.cmake. Please set S2DT_DIR environemnt variable.")
ENDIF(S2DT_CONFIG_CMAKE_SCRIPT)

