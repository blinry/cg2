# Try to find MathLink from Wolfram Mathematica package
#
# See http://www.wolfram.com/solutions/mathlink/
#
# Once run this will define: 
#
# MATHLINK_FOUND
# MATHLINK_INCLUDE_DIR
# MATHLINK_LIBRARIES
# MATHLINK_MPREP_BINARY
# 
# NOTES
# tested with Mathematica 5.1 (on Windows XP)
#
# AUTHOR
# Jan Woetzel <http://www.mip.informatik.uni-kiel.de/~jw> (03/2006)

# the precompiled MathLink library name depends on 
# - version (1 or 2) - we always use 2
# - compiler/linker  - MS Visual studio, mingw, borland, cygwin ...

#IF    (NOT MSVC)
IF (NOT WIN32)
  MESSAGE(STATUS "FindMathLink.cmake  is tested with WIN32 MSVC only. You may need to adapt the compiler dependant precompile libname to pick (which is ml32i2m for MSVC)")
ENDIF (NOT WIN32)
#ENDIF (NOT MSVC)

FIND_PATH(MATHLINK_INCLUDE_DIR mathlink.h
  $ENV{MATHLINK_DIR}/include
  $ENV{MATHLINK_DIR}
  $ENV{MATHLINK_HOME}/include
  $ENV{MATHLINK_HOME}
  $ENV{EXTRA}/include
  $ENV{EXTRA}
  "$ENV{ProgramFiles}/Wolfram Research/Mathematica/5.1/AddOns/MathLink/DeveloperKit/Windows/CompilerAdditions/mldev32/include"
)
#MESSAGE("DBG MATHLINK_INCLUDE_DIR=${MATHLINK_INCLUDE_DIR}")


  FIND_LIBRARY(MATHLINK_LIBRARY
    NAMES ml32i2m
    PATHS 
  $ENV{MATHLINK_DIR}/lib
  $ENV{MATHLINK_DIR}
  $ENV{MATHLINK_HOME}/lib
  $ENV{MATHLINK_HOME}
  $ENV{EXTRA}/include
  $ENV{EXTRA}
  "$ENV{ProgramFiles}/Wolfram Research/Mathematica/5.1/AddOns/MathLink/DeveloperKit/Windows/CompilerAdditions/mldev32/lib"
)
#MESSAGE("DBG MATHLINK_LIBRARY=${MATHLINK_LIBRARY}")


FIND_PROGRAM(MATHLINK_MPREP_BINARY 
 NAMES mprep 
 PATHS 
 "$ENV{ProgramFiles}/Wolfram Research/Mathematica/5.1/AddOns/MathLink/DeveloperKit/Windows/CompilerAdditions/mldev32/bin"
 DOC "Mathematica Mathlink mprep binary" )
  
# --------------------------------

IF(MATHLINK_LIBRARY)
  SET(MATHLINK_LIBRARIES ${MATHLINK_LIBRARY})
ELSE(MATHLINK_LIBRARY)
  MESSAGE(STATUS "MATHLINK_LIBRARY_2m library not found.")
ENDIF(MATHLINK_LIBRARY)

IF(NOT MATHLINK_INCLUDE_DIR)
  MESSAGE(STATUS "MATHLINK_INCLUDE_DIR include dir not found.")
ENDIF(NOT MATHLINK_INCLUDE_DIR)

IF   (NOT MATHLINK_MPREP_BINARY)
  MESSAGE(STATUS "MATHLINK_MPREP_BINARY not found.")
ENDIF(NOT MATHLINK_MPREP_BINARY)

IF   (MATHLINK_LIBRARIES AND MATHLINK_INCLUDE_DIR)
  SET(MATHLINK_FOUND TRUE)
ENDIF(MATHLINK_LIBRARIES AND MATHLINK_INCLUDE_DIR)
  

MARK_AS_ADVANCED(
  MATHLINK_LIBRARY
  MATHLINK_LIBRARIES
  MATHLINK_INCLUDE_DIR
  MATHLINK_MPREP_BINARY
  MATHLINK_FOUND
)
