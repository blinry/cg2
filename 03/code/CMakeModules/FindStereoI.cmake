# 
# Try to find StereoI library  
# which is an interface for the NVidia consumer stereo driver. 
# Once run this will define: 
# 
# STEREOI_FOUND
# STEREOI_INCLUDE_DIR
# STEREOI_LIBRARIES
# STEREOI_LINK_DIRECTORIES
##
# 2005/10
# Jan Woetzel
# www.mip.informatik.uni-kiel.de/~jw
# --------------------------------

IF (NOT WIN32)
  MESSAGE(SEND_ERROR "StereoI API is supported onyl on Win32. Please ask Jan Woetzel for details.")
ENDIF (NOT WIN32)


FIND_PATH(STEREOI_INCLUDE_DIR StereoI.h
  "${STEREOI_DIR}/include"
  "${STEREOI_DIR}"
  "$ENV{STEREOI_DIR}/include"
  "$ENV{STEREOI_DIR}"
  "$ENV{SOURCE_DIR}/StereoI/include"
  "$ENV{SOURCE_DIR}/StereoI"
)

FIND_LIBRARY(STEREOI_LIBRARY_Release
  NAMES StereoI
  PATHS 
  "$ENV{STEREOI_DIR}/lib/Release"
  "$ENV{STEREOI_DIR}/lib"
  "$ENV{STEREOI_DIR}/"
  "$STEREOI_DIR}/lib/Release"
  "$STEREOI_DIR}/lib"
  "$STEREOI_DIR}/"
  "$ENV{SOURCE_DIR}/StereoI/lib/Release"
  "$ENV{SOURCE_DIR}/StereoI/lib"
  "$ENV{SOURCE_DIR}/StereoI/"
)

FIND_LIBRARY(STEREOI_LIBRARY_Debug
  NAMES StereoId StereoI_d StereoI 
  PATHS 
  "$ENV{STEREOI_DIR}/lib/Debug"
  "$ENV{STEREOI_DIR}/lib"
  "$ENV{STEREOI_DIR}/"
  "$STEREOI_DIR}/lib/Debug"
  "$STEREOI_DIR}/lib"
  "$STEREOI_DIR}/"
  "$ENV{SOURCE_DIR}/StereoI/lib/Debug"
  "$ENV{SOURCE_DIR}/StereoI/lib"
  "$ENV{SOURCE_DIR}/StereoI/"
)


##
# all required found?
##
IF (STEREOI_INCLUDE_DIR)
  # found header
  IF   (STEREOI_LIBRARY_Debug OR STEREOI_LIBRARY_Release)  
  
    # found lib(s), now choose Debug/Release or both
    SET(STEREOI_FOUND TRUE)
    
    IF   (STEREOI_LIBRARY_Debug AND STEREOI_LIBRARY_Release)
      # both, Debug+Release available
      SET (STEREOI_LIBRARIES 
        debug     ${STEREOI_LIBRARY_Debug} 
        optimized ${STEREOI_LIBRARY_Release} )
      GET_FILENAME_COMPONENT(STEREOI_LINK_DIRECTORIES ${STEREOI_LIBRARY_Debug} PATH)  
    ELSE (STEREOI_LIBRARY_Debug AND STEREOI_LIBRARY_Release)
      # found only one of both to be used for both builds
      IF    (STEREOI_LIBRARY_Debug)
        # only Debug
        SET (STEREOI_LIBRARIES  ${STEREOI_LIBRARY_Debug} )        
        GET_FILENAME_COMPONENT(STEREOI_LINK_DIRECTORIES ${STEREOI_LIBRARY_Debug} PATH)
      ELSEIF(STEREOI_LIBRARY_Debug)
        # only Release
        SET (STEREOI_LIBRARIES  ${STEREOI_LIBRARY_Release} )
        GET_FILENAME_COMPONENT(STEREOI_LINK_DIRECTORIES ${STEREOI_LIBRARY_Release} PATH)            
      ENDIF (STEREOI_LIBRARY_Debug)      
    ENDIF(STEREOI_LIBRARY_Debug AND STEREOI_LIBRARY_Release)
    
  ELSE (STEREOI_LIBRARY_Debug OR STEREOI_LIBRARY_Release)
    MESSAGE("STEREOI libraries not found.")
  ENDIF(STEREOI_LIBRARY_Debug OR STEREOI_LIBRARY_Release)
ELSE  (STEREOI_INCLUDE_DIR)
  MESSAGE("STEREOI_INCLUDE_DIR not found.")
ENDIF (STEREOI_INCLUDE_DIR)


IF (NOT STEREOI_FOUND)
  MESSAGE("StereoI library not found. Please search manually or set shell variable STEREOI_DIR to guide search.")
ENDIF (NOT STEREOI_FOUND)

MARK_AS_ADVANCED(
  STEREOI_INCLUDE_DIR
  STEREOI_LIBRARIES
  STEREOI_LIBRARY_Debug
  STEREOI_LIBRARY_Release
)

