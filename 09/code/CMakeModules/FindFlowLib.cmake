# -Try to find FlowLib from TU Graz
#
# The following are set after configuration is done: 
#  FlowLib_FOUND
#  FlowLib_INCLUDE_DIR
#  FlowLib_LIBRARIES
#

MACRO(DBG_MSG _MSG)
#  MESSAGE(STATUS "${CMAKE_CURRENT_LIST_FILE}(${CMAKE_CURRENT_LIST_LINE}):\n${_MSG}")
ENDMACRO(DBG_MSG)

# Figure out which system we are on, aka 32-bit or 64-bit
IF( NOT FlowLib_ARCHITECTURE)
    EXEC_PROGRAM(uname
		 ARGS "-m"
		 OUTPUT_VARIABLE FlowLib_ARCHITECTURE)

    DBG_MSG(${FlowLib_ARCHITECTURE})
ENDIF(NOT FlowLib_ARCHITECTURE)


# Search all available major versions of the GPU lib
EXEC_PROGRAM(find 
  ARGS "/afs/cg.cs.tu-bs.de/lib/linux/c++/${FlowLib_ARCHITECTURE}/" "-name flowlib" 
  OUTPUT_VARIABLE FlowLib_ROOT_DIR)


DBG_MSG("Root: ${FlowLib_ROOT_DIR}")

SET(FlowLibREQCOMP flow common vm)

# Usual stuff to setup the library

FIND_PATH(FlowLib_INCLUDE_DIR FlowLib.h "${FlowLib_ROOT_DIR}/include/")
FIND_LIBRARY(FlowLib_flow  NAMES flow PATHS "${FlowLib_ROOT_DIR}/lib/") 
FIND_LIBRARY(FlowLib_vm  NAMES vm PATHS "${FlowLib_ROOT_DIR}/lib/") 
FIND_LIBRARY(FlowLib_common  NAMES common PATHS "${FlowLib_ROOT_DIR}/lib/") 
DBG_MSG("Include: ${FlowLib_INCLUDE_DIR}")
DBG_MSG("Lib: ${FlowLib_flow} ${FlowLib_vm} ${FlowLib_common}")

IF (FlowLib_INCLUDE_DIR AND FlowLib_flow AND FlowLib_vm AND FlowLib_common)
   SET(FlowLib_FOUND TRUE)
   FOREACH(NAME ${FlowLibREQCOMP})
     LIST(APPEND FlowLib_LIBRARIES ${FlowLib_${NAME}} )
   ENDFOREACH(NAME)
   DBG_MSG("Lib: ${FlowLib_LIBRARIES}")
ENDIF (FlowLib_INCLUDE_DIR AND FlowLib_flow AND FlowLib_vm AND FlowLib_common)

IF (FlowLib_FOUND)
   IF (NOT FlowLib_FIND_QUIETLY)
      MESSAGE(STATUS "Found FlowLib: ${FlowLib_ROOT_DIR}")
   ENDIF (NOT FlowLib_FIND_QUIETLY)
ELSE (FlowLib_FOUND)
   IF (FlowLib_FIND_REQUIRED)
      MESSAGE(FATAL_ERROR "Could not find FlowLib")
   ENDIF (FlowLib_FIND_REQUIRED)
ENDIF (FlowLib_FOUND)

