# 
# Try to find Visual Leak Debugger librarry (VDL)
# See http://www.codeproject.com/tools/visualleakdetector.asp for details
##
# Once run this will define: 
# 
# VLD_FOUND
# VLD_INCLUDE_DIR 
##
# Jan Woetzel 08/2005
# www.mip.informatik.uni-kiel.de/~jw
##
# tested with vdl-1.0 on Windows with Visual Studio .Net 2003
##
# --------------------------------
SET(VLD_FOUND FALSE)

# VLD works only in Microsoft Visual Studio on Windows:
IF(WIN32)
IF(CMAKE_BUILD_TOOL MATCHES "(msdev|devenv)")


FIND_PATH(VLD_INCLUDE_DIR vld.h
  $ENV{VLD_DIR}/include
  $ENV{VLD_DIR}
  $ENV{VLD_HOME}/include
  $ENV{VLD_HOME}
  "$ENV{ProgramFiles}/Microsoft Visual Studio .NET 2003/Vc7/include"
 )
#MESSAGE("VLD_INCLUDE_DIR=${VLD_INCLUDE_DIR}")

# this is just required for runtim enabling/disabling: 
FIND_PATH(VLD_INCLUDE_DIR_API vldapi.h
  $ENV{VLD_DIR}/include
  $ENV{VLD_DIR}  
  $ENV{VLD_HOME}/include
  $ENV{VLD_HOME}
  "$ENV{ProgramFiles}/Microsoft Visual Studio .NET 2003/Vc7/include"
 )
#MESSAGE("VLD_INCLUDE_DIR_API=${VLD_INCLUDE_DIR}")



FIND_LIBRARY(VLD_LIBRARY_VLD
  NAMES vld
  PATHS 
  $ENV{VLD_DIR}/lib
  $ENV{VLD_DIR}
  $ENV{VLD_HOME}/lib
  $ENV{VLD_HOME}
  "$ENV{ProgramFiles}/Microsoft Visual Studio .NET 2003/Vc7/lib"
  DOC "Visual Leak Debugger multithreaded library"
  )
#MESSAGE("VLD_LIBRARY_VLD=${VLD_LIBRARY_VLD}")


FIND_LIBRARY(VLD_LIBRARY_VLDMT
  NAMES vldmt
  PATHS 
  $ENV{VLD_DIR}/lib
  $ENV{VLD_DIR}
  $ENV{VLD_HOME}/lib
  $ENV{VLD_HOME}
  "$ENV{ProgramFiles}/Microsoft Visual Studio .NET 2003/Vc7/lib"
  DOC "Visual Leak Debugger multithreaded library"
  )
#MESSAGE("VLD_LIBRARY_VLDMT=${VLD_LIBRARY_VLDMT}")

FIND_LIBRARY(VLD_LIBRARY_VLDMTDLL
  NAMES vldmtdll
  PATHS 
  $ENV{VLD_DIR}/lib
  $ENV{VLD_DIR}
  $ENV{VLD_HOME}/lib
  $ENV{VLD_HOME}
  "$ENV{ProgramFiles}/Microsoft Visual Studio .NET 2003/Vc7/lib"
  DOC "Visual Leak Debugger multithreaded library"
  )
#MESSAGE("VLD_LIBRARY_VLDMTDLL=${VLD_LIBRARY_VLDMTDLL}")


IF(VLD_INCLUDE_DIR)
  IF (VLD_LIBRARY_VLD OR VLD_LIBRARY_VLDMT OR VLD_LIBRARY_VLDMTDLL)
    # do NOT add LIBRARIES because dependencies are handled through pragmas.
    SET(VLD_FOUND TRUE)
    # MESSAGE("found VLD.")
  ENDIF (VLD_LIBRARY_VLD OR VLD_LIBRARY_VLDMT OR VLD_LIBRARY_VLDMTDLL)
ENDIF(VLD_INCLUDE_DIR)


MARK_AS_ADVANCED(
  VLD_INCLUDE_DIR
  VLD_INCLUDE_DIR_API
  VLD_LIBRARY_VLD
  VLD_LIBRARY_VLDMT
  VLD_LIBRARY_VLDMTDLL
  VLD_LIBRARIES
)



ENDIF(CMAKE_BUILD_TOOL MATCHES "(msdev|devenv)")
ENDIF(WIN32)
