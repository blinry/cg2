# Try to find xml2  library
#
# Once run this will define:
#
# XML2_FOUND
# XML2_LIBRARIES
# XML2_INCLUDE_DIR
# XML2_LINK_DIRECTORIES
# XML2_EXE_LINKER_FLAGS
#
# Friso, Birger and Jan Woetzel 2004/06 and 2004/07
# Jan Woetzel 2004/12: major rewrite using CMakeOutput.log (12/2004)
# www.mip.informatik.uni-kiel.de/
#
# TODO
# CHECK_SYMBOL_EXISTS can be used as a more elegant solution.
#


SET(XML2_POSSIBLE_INCLUDE_PATHS
  ${XML2_DIR}
  $ENV{XML2_DIR}
  $ENV{XML2_DIR}/include
  $ENV{XML2_DIR}/include/libxml2
  ${XML2_HOME}  
  $ENV{XML2_HOME}
  $ENV{XML2_HOME}/include
  $ENV{XML2_HOME}/include/libxml2
  $ENV{EXTRA}/include
  $ENV{EXTRA}  
  ENV{ICONV_DIR}/include
  ENV{ICONV_DIR}
  ENV{ICONV_HOME}}/include
  ENV{ICONV_HOME}
  /usr/include/libxml2
  /usr/local/include/libxml2
  )


SET(XML2_POSSIBLE_LIBRARY_PATHS
  ${XML2_DIR}
  $ENV{XML2_DIR}
  $ENV{XML2_DIR}/lib
  ${XML2_HOME}
  $ENV{XML2_HOME}
  $ENV{XML2_HOME}/lib
  $ENV{EXTRA}/lib
  $ENV{EXTRA}
  ENV{ICONV_DIR}/lib
  ENV{ICONV_DIR}
  ENV{ICONV_HOME}}/lib
  ENV{ICONV_HOME}
  /usr/lib
  /usr/local/lib
  )


#
# Find key files to determine all settings: 
#
FIND_PATH(XML2_INCLUDE_DIR libxml/parser.h
  ${XML2_POSSIBLE_INCLUDE_PATHS}
  )

FIND_LIBRARY(XML2_LIBRARY
  NAMES xml2 libxml2
  PATHS ${XML2_POSSIBLE_LIBRARY_PATHS}
  )


IF(WIN32) 
  # On WIN32 XML2 need an additional ..._a lib and iconv (JW 12/2004)
  FIND_LIBRARY(XML2_A_LIBRARY
    NAMES libxml2_a
    PATHS ${XML2_POSSIBLE_LIBRARY_PATHS}
    )
  # TODO: intergrate this into a new FindIconv.cmake file
  FIND_PATH(ICONV_INCLUDE_DIR iconv.h
    ${XML2_POSSIBLE_INCLUDE_PATHS}
    )
ENDIF(WIN32)



#
# determine wether the things we found are complete
# init with OK and reset to false of any error is detected
SET (XML2_FOUND TRUE)

# lib found ? 
IF(NOT XML2_LIBRARY)
  SET (XML2_FOUND FALSE)
  #  MESSAGE(STATUS "XML2_LIBRARY not found.  Please set XML2_DIR to find it. XML2_LIBRARY=${XML2_LIBRARY}")
  MESSAGE( "XML2_LIBRARY not found.  Please set XML2_DIR to find it. XML2_LIBRARY=${XML2_LIBRARY}")
  FILE(APPEND ${PROJECT_BINARY_DIR}/CMakeOutput.log
    "XML2 lib not found.  XML2_LIBRARY=${XML2_LIBRARY}")
ENDIF(NOT XML2_LIBRARY)

# header found ?
IF(NOT XML2_INCLUDE_DIR)
  SET (XML2_FOUND FALSE)
  MESSAGE(STATUS "XML2_INCLUDE_DIR not found. Please set XML2_DIR to find it. XML2_INCLUDE_DIR=${XML2_INCLUDE_DIR}")
  FILE(APPEND ${PROJECT_BINARY_DIR}/CMakeOutput.log
    "XML2_INCLUDE_DIR not found. Please set XML2_DIR to find it. XML2_INCLUDE_DIR=${XML2_INCLUDE_DIR}")
ENDIF(NOT XML2_INCLUDE_DIR)


# iconv header for Win32?
#IF(WIN32 AND NOT ICONV_INCLUDE_DIR)
#  SET(XML2_FOUND FALSE)
#  MESSAGE(STATUS "XML2: ICONV_INCLUDE_DIR not found but required on WIN32. S ICONV_HOME or path for iconv.h")
#  FILE(APPEND ${PROJECT_BINARY_DIR}/CMakeOutput.log
  #    "XML2: ICONV_INCLUDE_DIR not found but required on WIN32. S ICONV_HOME or path for iconv.h")
#ENDIF(WIN32 AND NOT ICONV_INCLUDE_DIR)

# second _a lib for Win32 ?
#IF(WIN32 AND NOT XML2_A_LIBRARY)
#  SET(XML2_FOUND FALSE)
#  MESSAGE(STATUS "XML2:  XML2_A_LIBRARY not found but required on WIN32.") 
#  FILE(APPEND ${PROJECT_BINARY_DIR}/CMakeOutput.log 
  #    "XML2:  XML2_A_LIBRARY not found but required on WIN32.")    
#ENDIF(WIN32 AND NOT XML2_A_LIBRARY)



# try to compile a small example
# to check for function "xmlValidateName"
# which is available only in newer libxml2 versions >= 2.5.10 
# THIS test shoudl usually tbe the last because it is using all obove headers/libs.
# TODO: use thsi test on WIN32, too. 
# TODO HACK FIXME: this does not work fw
#IF (UNIX AND XML2_FOUND)
#  MESSAGE(STATUS "Looking for xmlValidateName in xml2 library=${XML2_LIBRARY}")
#  TRY_COMPILE(XML2_VALIDATE_NAME_FOUND
  #    ${CMAKE_MODULE_PATH}
  #    ${CMAKE_MODULE_PATH}/TestXML2Version.cpp
  #    CMAKE_FLAGS -DINCLUDE_DIRECTORIES:STRING=${XML2_INCLUDE_DIR} -DLINK_DIRECTORIES:STRING=${XML2_LINK_DIRECTORIES} -DLINK_LIBRARIES:STRING=${XML2_LIBRARY}
  #    OUTPUT_VARIABLE XML2_VALIDATE_NAME_OUT
  #    )
#  #MESSAGE("DGB compile: XML2_VALIDATE_NAME_FOUND=${XML2_VALIDATE_NAME_FOUND} output:\n ${XML2_VALIDATE_NAME_OUT}")
#  IF(XML2_VALIDATE_NAME_FOUND)
#    MESSAGE(STATUS "Looking for xmlValidateName in xml2 library=${XML2_LIBRARY} - found")    
#  ELSE(XML2_VALIDATE_NAME_FOUND)
#    MESSAGE(STATUS "Looking for xmlValidateName in xml2 library=${XML2_LIBRARY} - not found")
#  ENDIF(XML2_VALIDATE_NAME_FOUND)      
#ENDIF(UNIX AND XML2_FOUND) 
#
#
#
# version supported ?
#IF(UNIX AND NOT XML2_VALIDATE_NAME_FOUND)
#  SET (XML2_FOUND FALSE)
#  MESSAGE(STATUS "XML2_VALIDATE_NAME found but does not work. Too old? Please install newer version >=2.5.10 ")
#  FILE(APPEND ${PROJECT_BINARY_DIR}/CMakeOutput.log
  #    "XML2_VALIDATE_NAME found but does not work. Too old? Please install newer version >=2.5.10 ")
#ENDIF(UNIX AND NOT XML2_VALIDATE_NAME_FOUND)


#
# if still FOUND here then everything is OK.
#
IF (XML2_FOUND)
  # collect all libs we need, which is usually only one
  SET (XML2_LIBRARIES ${XML2_LIBRARY} )  
  # extract main link directory, useful for rpath and runtime loading of libraries 
  GET_FILENAME_COMPONENT(XML2_LINK_DIRECTORIES ${XML2_LIBRARY} PATH)
  
  ## we need ICONV on WIN32, too.
  IF (WIN32)
    SET (XML2_INCLUDE_DIR ${XML2_INCLUDE_DIR} ${ICONV_INCLUDE_DIR} )
    SET (XML2_LIBRARIES   ${XML2_LIBRARIES} ${XML2_A_LIBRARY} )  
  ENDIF(WIN32)

  
  # JW: The following was disabled and shouldn't be done, because
  # (1) it's dirty and not required, 
  # (2) rpath is handled automatically through LINK_DIRECTORIES unless user disbales it through SKIP_RPATH 
  #SET(XML2_EXE_LINKER_FLAGS "-Wl,-rpath,${XML2_PREFIX}")
ENDIF(XML2_FOUND)


# save the result to logfile
#FILE(APPEND ${PROJECT_BINARY_DIR}/CMakeOutput.log
  #  "XML2_FOUND=${XML2_FOUND}   as:\n"
  #  "  XML2_INCLUDE_DIR: ${XML2_INCLUDE_DIR}\n"
  #  "  XML2_LIBRARIES: ${XML2_LIBRARIES}\n"
  #  "  XML2_LIBRARY: ${XML2_LIBRARY}\n"
  #  )

# hide options that may confuse the normal user. They are visible in advanced mode, only.
MARK_AS_ADVANCED(
  XML2_INCLUDE_DIR
  XML2_LIBRARIES
  XML2_LIBRARY  
  XML2_A_LIBRARY
  ICONV_INCLUDE_DIR
  )
