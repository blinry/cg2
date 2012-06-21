#
# Helper macros for logging to file
#
# Jan Woetzel
#


MACRO(DBG_MSG _MSG)
  #MESSAGE(STATUS "${CMAKE_CURRENT_LIST_FILE}(${CMAKE_CURRENT_LIST_LINE}) : ${_MSG}")
  FILE(APPEND ${PROJECT_BINARY_DIR}/CMakeOutput.log  "${_MSG}")
ENDMACRO(DBG_MSG)
