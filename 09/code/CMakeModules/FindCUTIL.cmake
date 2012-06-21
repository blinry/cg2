# 
# Try to find CUTIL header files  
# Once run this will define: 
# 
# CUTIL_FOUND
# CUTIL_INCLUDE_DIR
#
# Martin Eisemann 01/2010. 
# http://www.cg.cs.tu-bs.de/people/eisemann/index.html
# --------------------------------

FIND_PATH(CUTIL_INCLUDE_DIR cutil.h
  /usr/include
  /usr/local/include
  $ENV{HOME}/NVIDIA_GPU_Computing_SDK/C/common/inc
  $ENV{HOME}/NVIDIA_CUDA_SDK/C/common/inc
  $ENV{HOME}/lib64/CUDA_SDK/C/common/inc
  )
#MESSAGE("DBG GLEW_INCLUDE_DIR=${GLEW_INCLUDE_DIR}")  

# --------------------------------

IF(NOT CUTIL_INCLUDE_DIR)
  MESSAGE(SEND_ERROR "CUTIL include dir not found.")
ENDIF(NOT CUTIL_INCLUDE_DIR)


IF(CUTIL_INCLUDE_DIR)
  SET(CUTIL_FOUND TRUE)
ENDIF(CUTIL_INCLUDE_DIR)


MARK_AS_ADVANCED(
  CUTIL_INCLUDE_DIR
  )
