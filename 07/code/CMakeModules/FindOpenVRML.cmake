# Try to find OpenVRML library
#
# OpenVRML_FOUND
# OpenVRML_INCLUDE_DIR
# OpenVRML_LIBRARY

find_path(OpenVRML_INCLUDE_DIR openvrml/vrml97_grammar.h
  /usr/include/openvrml
  /usr/local/include/openvrml
)

find_library(OpenVRML_LIBRARY
 NAMES openvrml 
 PATHS /usr/lib /usr/lib64 /usr/local/lib /usr/local/lib64
)

if(NOT OpenVRML_INCLUDE_DIR)
 message(SEND_ERROR "OpenVRML include dir not found.")
endif(NOT OpenVRML_INCLUDE_DIR)

IF(OpenVRML_LIBRARY AND OpenVRML_INCLUDE_DIR)
 set(OpenVRML_FOUND TRUE)
ELSE(OpenVRML_LIBRARY AND OpenVRML_INCLUDE_DIR)
 set(OpenVRML_FOUND FALSE)
 message(SEND_ERROR "OpenVRML not found.")
ENDIF(OpenVRML_LIBRARY AND OpenVRML_INCLUDE_DIR)