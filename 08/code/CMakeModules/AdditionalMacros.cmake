#
# additional user defined macros
# for use with CMake build system. 
# 
# Jan Woetzel
# www.mip.informatik.uni-kiel.de/~jw
#


# helper macro to clean a variable "in place"
# 2. removes all spaces at beginning and end of line
# 3. joins multiple space "  " into in " "
# useful to avoid double bracketing with regular expressions
# and override CXX_FLAGS
# author Jan Woetzel 11/2005
MACRO(CLEAN_LINE VARNAME)
  # replace multi spaces by single space
  STRING(REGEX REPLACE "[ ]+"   " "
    ${VARNAME}  "${${VARNAME}}" )
  
  # remove (multiple) spaces at beginning of line  which may remain
  STRING(REGEX REPLACE "^[ ]+"   ""
    ${VARNAME}  "${${VARNAME}}" )  
  
  # remove spaces at end of line which may remain
  STRING(REGEX REPLACE "[ ]+$"   ""
    ${VARNAME}  "${${VARNAME}}" )
ENDMACRO(CLEAN_LINE VARNAME)

