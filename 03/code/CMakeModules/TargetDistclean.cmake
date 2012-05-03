# add custom target distclean
# cleans and removes cmake generated files etc.
# Jan Woetzel 04/2003
# www.mip.informatik.uni-kiel.de/~jw
##
# TODO : change rm/delete to cmake -E 's built in delete (JW)
##

IF (UNIX)
  ADD_CUSTOM_TARGET(distclean)
  ADD_DEPENDENCIES (distclean clean)
  
  SET(DISTCLEAN_FILES
    cmake.depends
    cmake.check_depends
    CMakeCache.txt
    cmake.check_cache
    CMakeOutput.log
    core core.*
    gmon.out bb.out
    *~ 
    *%
    SunWS_cache
    ii_files
    *.so
    *.o
    *.a
    CopyOfCMakeCache.txt
    CMakeCCompiler.cmake
    CMakeCXXCompiler.cmake
    CMakeSystem.cmake 
    html latex Doxyfile 
    )

  SET(DISTCLEAN_DIRS
    CMakeTmp
    )

SET(DISTCLEAN_RECURSIVE_FILES
  Makefile
  cmake_install.cmake
  cmake.check_depends
  cmake.depends
)

  # for 1.8.x:
  ADD_CUSTOM_COMMAND(
    TARGET distclean
    PRE_BUILD
    COMMAND rm
    ARGS    -Rf ${DISTCLEAN_FILES} ${DISTCLEAN_DIRS}
   COMMENT
    )

  
  FOREACH(RMTARGET ${DISTCLEAN_RECURSIVE_FILES})
    ADD_CUSTOM_COMMAND(
      TARGET distclean
      PRE_BUILD
      COMMAND find
      ARGS . -name ${RMTARGET} -exec rm {} '\;'
      COMMENT
      )
  ENDFOREACH(RMTARGET ${DISTCLEAN_RECURSIVE_FILES})
  
  
ENDIF(UNIX)
