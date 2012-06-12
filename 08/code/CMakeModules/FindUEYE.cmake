# serach for IDS uEye SDK  and set the following variables:
# UEYE_FOUND
# UEYE_INCLUDE_DIR
# UEYE_LIBRARIES


   IF(WIN32)  
    FIND_PATH(IDS_UEYE_SDK "include/uEye.h"
      "$ENV{ProgramFiles}/IDS/uEye/Develop/")    
   ELSE(WIN32)	    
    FIND_PATH(IDS_UEYE_SDK "include/uEye.h" "/usr/")	
   ENDIF(WIN32) 
   
   IF(IDS_UEYE_SDK)
     # MESSAGE(" uEye is used from: ${IDS_UEYE_SDK}")
      SET(UEYE_INCLUDE_DIR ${IDS_UEYE_SDK})
      IF(WIN32)
	SET(UEYE_LIBRARIES "${IDS_UEYE_SDK}/Lib/uEye_api.lib")   
      ELSE(WIN32)
	SET(UEYE_LIBRARIES "${IDS_UEYE_SDK}/lib/libueye_api.so")
      ENDIF(WIN32)

   SET(UEYE_FOUND TRUE)

   ELSE(IDS_UEYE_SDK)
     SET(UEYE_FOUND FALSE)
   ENDIF(IDS_UEYE_SDK)
 

 