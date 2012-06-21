# -Try to find CG-TUBS GPU library
# see http://elara/cgwiki/Our_GPU_Lib
#
# The follwoing variables are optionally searched for defaults
# GPULib_MAJOR_VERSION : Use this version instead of the latest
#
# The following are set after configuration is done: 
#  GPULib_FOUND
#  GPULib_INCLUDE_DIR
#  GPULib_LIBRARY
#

MACRO(DBG_MSG _MSG)
   MESSAGE(STATUS "${CMAKE_CURRENT_LIST_FILE}(${CMAKE_CURRENT_LIST_LINE}):\n${_MSG}")
ENDMACRO(DBG_MSG)

# Figure out which system we are on, aka 32-bit or 64-bit
IF( NOT GPULib_ARCHITECTURE)
    EXEC_PROGRAM(uname
		 ARGS "-m"
		 OUTPUT_VARIABLE GPULib_ARCHITECTURE)

    DBG_MSG(${GPULib_ARCHITECTURE})
ENDIF(NOT GPULib_ARCHITECTURE)

IF(NOT GPULib_UBUNTU)
  EXEC_PROGRAM(cat 
               ARGS "/etc/issue | sed 's/\\(.*\\)\\\\n.*/\\1/' | sed 's/ //g'"
	       OUTPUT_VARIABLE GPULib_UBUNTU)
  DBG_MSG(${GPULib_UBUNTU})	     
ENDIF(NOT GPULib_UBUNTU)

# Figure out all available major versions and use the latest or use the one specified as optional input
IF (NOT GPULib_MAJOR_VERSION)
   # Search all available major versions of the GPU lib
   EXEC_PROGRAM(find 
		  ARGS "/afs/cg.cs.tu-bs.de/lib/linux/c++/${GPULib_ARCHITECTURE}/${GPULib_UBUNTU}/" "-name gpulib-*" 
		  OUTPUT_VARIABLE GPULib_POSSIBLE_DIRS)

   DBG_MSG("Possible dirs: ${GPULib_POSSIBLE_DIRS}")
   DBG_MSG("Available versions: ${GPULib_AVAILABLE_VERSIONS}")

   STRING(REGEX MATCHALL "-[0-9]+" GPULib_AVAILABLE_VERSIONS "${GPULib_POSSIBLE_DIRS}")
 DBG_MSG("Available versions: ${GPULib_AVAILABLE_VERSIONS}")	
   LIST(SORT GPULib_AVAILABLE_VERSIONS)

   LIST(GET GPULib_AVAILABLE_VERSIONS -1 GPULib_MAJOR_VERSION)
   DBG_MSG("Major version: ${GPULib_MAJOR_VERSION}")
ENDIF (NOT GPULib_MAJOR_VERSION)


# Now that we definetly have the desired major version we can build the root directory
SET( GPULib_ROOT_DIR "/afs/cg.cs.tu-bs.de/lib/linux/c++/${GPULib_ARCHITECTURE}/${GPULib_UBUNTU}/gpulib${GPULib_MAJOR_VERSION}/")

DBG_MSG("Root: ${GPULib_ROOT_DIR}")

# Usual stuff to setup the library

FIND_PATH(GPULib_INCLUDE_DIR OpenGLState.h "${GPULib_ROOT_DIR}/include/")
FIND_LIBRARY(GPULib_LIBRARY gpu "${GPULib_ROOT_DIR}/lib/") 
DBG_MSG("Include: ${GPULib_INCLUDE_DIR}")
DBG_MSG("Lib: ${GPULib_LIBRARY}")

FIND_FILE(GPULib_SHADERDB_GENERATOR create_shaderdb "${GPULib_ROOT_DIR}/bin/")
FIND_FILE(GPULib_SHADERDB_BOILERPLATE BoilerplateShaderDB ${GPULib_INCLUDE_DIR})

DBG_MSG(${GPULib_INCLUDE_DIR})
DBG_MSG(${GPULib_LIBRARY})

IF (GPULib_INCLUDE_DIR AND GPULib_LIBRARY)
   SET(GPULib_FOUND TRUE)
ENDIF (GPULib_INCLUDE_DIR AND GPULib_LIBRARY)

IF (GPULib_FOUND)
   IF (NOT GPULib_FIND_QUIETLY)
      MESSAGE(STATUS "Found GPULib: ${GPULib_ROOT_DIR}")
   ENDIF (NOT GPULib_FIND_QUIETLY)
ELSE (GPULib_FOUND)
   IF (GPULib_FIND_REQUIRED)
      MESSAGE(FATAL_ERROR "Could not find GPULib")
   ENDIF (GPULib_FIND_REQUIRED)
ENDIF (GPULib_FOUND)


MACRO(GPULib_ShaderDBFromDir)
    SET( _shaderdb_name_ ${ARGV0} )

    GET_FILENAME_COMPONENT(_shaderdb_abs_path_ ${ARGV1} ABSOLUTE)
    SET(_shaderdb_abs_path_ "${_shaderdb_abs_path_}/")

    DBG_MSG(${_shaderdb_abs_path_})

    FILE(GLOB _shader_files_ RELATIVE ${_shaderdb_abs_path_} "${_shaderdb_abs_path_}*.frag" "${_shaderdb_abs_path_}*.vert" "${_shaderdb_abs_path_}*.geom" "${_shaderdb_abs_path_}*.glsl")
    FILE(GLOB _abs_shader_files_ "${_shaderdb_abs_path_}*.frag" "${_shaderdb_abs_path_}*.vert" "${_shaderdb_abs_path_}*.geom" "${_shaderdb_abs_path_}*.glsl")
    
#    DBG_MSG("${GPULib_SHADERDB_GENERATOR} ${_shaderdb_name_} ${CMAKE_CURRENT_SOURCE_DIR} ${GPULib_SHADERDB_BOILERPLATE} ${_shaderdb_abs_path_} ${_shader_files_}")
    
    ADD_CUSTOM_COMMAND(OUTPUT ${CMAKE_CURRENT_SOURCE_DIR}/${_shaderdb_name_}.cpp ${CMAKE_CURRENT_SOURCE_DIR}/${_shaderdb_name_}.h
    COMMAND ${GPULib_SHADERDB_GENERATOR} ${_shaderdb_name_} ${CMAKE_CURRENT_SOURCE_DIR} ${GPULib_SHADERDB_BOILERPLATE} ${_shaderdb_abs_path_} ${_shader_files_}
    DEPENDS ${_abs_shader_files_}
    )

ENDMACRO(GPULib_ShaderDBFromDir)
