# 
# This convenience include finds if MIP is installed
# and set the appropriate libs, incdirs, flags etc. 
# @author Jan Woetzel <jw -at- mip.informatik.uni-kiel.de> (07/2003)
##
# -----------------------------------------------------
##
##
# This file is DEPRECATED because it's no good idea to add LINK_LIBRARIES to all childs globally.
# And PackageConfig is supported, now. (JW)
# 
# Please use:
##
#   FIND_PACKAGE(MIP REQUIRED)
#   INCLUDE(${MIP_USE_FILE})
#   TARGET_LINK_LIBARIES( yourExecutable all libs you need )
##
# and add dependencies per target manually
# instead of deprecated:
#   INCLUDE( ${CMAKE_MODULE_PATH}/Use_MIP.cmake)
##
# ------------------------------------------------------------------
# @author Jan Woetzel <http://www.mip.informatik.uni-kiel.de/~jw> (07/2003)
# *deprecated* 06/2004 (JW)
# ------------------------------------------------------------------


MESSAGE(
STATUS 
"\t*** DEPRECATED WARNING: ${CMAKE_MODULE_PATH} Use_MIP.cmake is deprecated. ***\n"
"\tPlease use FIND_PACKAGE(MIP) \n"
"\tINCLUDE($MIP_USE_FILE}) \n"
"\tTARGET_LINK_LIBRARIES, instead.\n"
"\t (Jan Woetzel 06/2004)"
)



FIND_PACKAGE(MIP REQUIRED)

IF(MIP_FOUND)

  IF (MIP_USE_FILE)
    # The use file handles all the lines below.
    INCLUDE(${MIP_USE_FILE})
  ELSE (MIP_USE_FILE)
    MESSAGE(SEND_ERROR "MIP found but MIP_USE_FILE not found !!!")
  ENDIF (MIP_USE_FILE)
  
ELSE(MIP_FOUND)
  MESSAGE(SEND_ERROR "MIP not found by Use_MIP.cmake")
ENDIF(MIP_FOUND)
