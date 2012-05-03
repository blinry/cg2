#
# override CMake predefined compiler/linker flags once
# and set additional OS/compiler specific flags,
# e.g. architecture optimized options
#
# Jan-Felix Woelk and Jan Woetzel 07/2004,2005
# major rewrite by Jan Woetzel 11/2005
#
# www.mip.informatik.uni-kiel.de/~jw
#

# cmakes default entries should be overridden exactly once
# to allow interactuve user changes. (JW)
# Avoid FORCE because user will not be able to change cvalues, then. 

# allow gcc compilation on Windows (jw)
IF(WIN32)
  SET(WIN32_STYLE_FLAGS 1)
ENDIF(WIN32)
IF(MINGW)
  SET(WIN32_STYLE_FLAGS 0)
  SET(UNIX_STYLE_FLAGS  1)
ENDIF(MINGW)
IF(UNIX)
  SET(WIN32_STYLE_FLAGS 0)
  SET(UNIX_STYLE_FLAGS  1)  
ENDIF(UNIX)



#
# helper macro to clean a variable "in place"
# 2. removes all spaces at beginning and end of line
# 3. joins multiple space "  " into in " "
# useful to avoid double bracketing with regular expressions
# and override CXX_FLAGS
# author Jan Woetzel 11/2005
#
MACRO(CLEAN_LINE VARNAME)
  # replace multi spaces by single space
  STRING(REGEX REPLACE "[ ]+"   " "
    ${VARNAME}  "${${VARNAME}}" )

  # remove (multiple) spaces at beginning of line  which may remain
  STRING(REGEX REPLACE "^[ ]+"   ""
    ${VARNAME}  "${${VARNAME}}" )  

  # remove spaces at end of line which may remain
  # this is required because the string 
  # would get an extra escapement if it ends with space
  STRING(REGEX REPLACE "[ ]+$"   ""
    ${VARNAME}  "${${VARNAME}}" )
ENDMACRO(CLEAN_LINE VARNAME)




# ---------------------------------------------------
#
# options useful for all builds /OS
#
# ---------------------------------------------------

#
# shows args of compiler run 
# (cmake internal function)
# 
OPTION(CMAKE_VERBOSE_MAKEFILE "create verbose compiling information?" TRUE)
MARK_AS_ADVANCED(CMAKE_VERBOSE_MAKEFILE)

# full nmake command line:
#SET(CMAKE_START_TEMP_FILE "")
#SET(CMAKE_END_TEMP_FILE   "")

# requres cmake >= 2.4.
OPTION(CMAKE_COLOR_MAKEFILE "show color in makefile output?" OFF)
#MARK_AS_ADVANCED(CMAKE_COLOR_MAKEFILE)



# add header files to target just for Visual Studio projects integrated development environment (IDE)
# as of CMake 2.4 this is obsolete because .hh files are correctly ignored in Makefile generators, now.
IF    (CMAKE_BUILD_TOOL MATCHES "(msdev|devenv)")
  SET(VISUAL_IDE TRUE)
ELSE  (CMAKE_BUILD_TOOL MATCHES "(msdev|devenv)")
  SET(VISUAL_IDE FALSE)
ENDIF (CMAKE_BUILD_TOOL MATCHES "(msdev|devenv)")



# build ADD_LIBRARY taret shared (or static) ? 
# should be default on Linux for faster turnaround 
# but not on Windows because of complex dllexport
# cmake inetrnal function 
IF (WIN32_STYLE_FLAGS)
  OPTION(BUILD_SHARED_LIBS "enable building shared(.dll) instead of static libs?" OFF)
ELSE (WIN32_STYLE_FLAGS)
  OPTION(BUILD_SHARED_LIBS "enable building shared(.so) instead of static libs?" ON)
ENDIF (WIN32_STYLE_FLAGS)



IF (WIN32_STYLE_FLAGS)
  # useful for debugging include hierarchy: (jw)
  # implemented by JW at the end of thsi file as substitution 
  OPTION(SHOW_INCLUDES "show includes hierarchy - verbose but slow (/showIncludes)?" OFF )
  MARK_AS_ADVANCED(SHOW_INCLUDES)

  # switch /nodefaultibs on/off
  #JW: DEPRECATED  OPTION(NODEFAULTLIBS_OVERRIDE "use NODEFAULTLIB settings to avoid clash between system libs?" ON)

ENDIF (WIN32_STYLE_FLAGS)




# ---------------------------------------------------
#
# forced override settings only once
#
# ---------------------------------------------------


IF (NOT  DEFINEFLAGS_HAS_RUN)
  # this is the first interactive cmake configure run.
  # override values by setting forced, then "disable" overriding
  # to let the user edit them interactively.

  MESSAGE(STATUS "  DefineFlags is overriding cache values (should appear only once)")

  # determines the build flags used for compilation 
  # use Debug build as default
  IF (NOT CMAKE_BUILD_TYPE)
    #MESSAGE(STATUS "DBG setting CMAKE_BUILD_TYPE (once) because it does not exits.")
    SET(CMAKE_BUILD_TYPE "Debug" CACHE STRING  "build type determining compiler flags" FORCE )
  #ELSE (NOT CMAKE_BUILD_TYPE)
  #  IF (CMAKE_BUILD_TYPE MATCHES "")
  #    MESSAGE("DBG setting CMAKE_BUILD_TYPE once beacuse it is empty. CMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}")
  #    SET(CMAKE_BUILD_TYPE "Debug" CACHE STRING  "build type determining compiler flags" FORCE )
  #  ENDIF (CMAKE_BUILD_TYPE MATCHES "")
  ENDIF (NOT CMAKE_BUILD_TYPE)

  # ---------------------------------------------------
  #
  # override CMake initialized flags once forced
  # other values should be added to cache for persistency
  #
  # ---------------------------------------------------  

  IF (UNIX_STYLE_FLAGS)

    # shall we save fullpath information in (shared) libs 
    # to find the corresponding lib during rutime (or use LD_RUNPATH)
    SET(CMAKE_SKIP_RPATH OFF 
      CACHE STRING "if set, runtime paths are NOT added when using shared libaries" FORCE)
     
    # cmakes default debug build does not include -Wall, unfortunately.
    # edit "standard build" flags provided by cmake:
    # -do not warn on "long long" type (int64) although it's not ISO ++ standard. (JW)
    # see http://gcc.gnu.org/onlinedocs/gcc/Warning-Options.html 
    SET(CMAKE_CXX_FLAGS_DEBUG 
      "-g -Wall -pedantic -g3 -ggdb -gdwarf-2 -Wunused-variable -Wno-long-long -Wno-unknown-pragmas -Wno-system-headers"
      #"-g -Wall -pedantic -Wunused-variable -Wno-long-long -Wno-unknown-pragmas"
      #"-g -Wall -pedantic -Wno-long-long -Wuninitialized -Wunreachable-code -Wunused -Wunused-function -Wunused-variable -Wunused-parameter -Wunreachable-code -O0"
      CACHE STRING "Debug builds CMAKE CXX flags " FORCE )
    SET(CMAKE_C_FLAGS_DEBUG "-g -Wall -pedantic -g3 -ggdb -gdwarf-2"
      CACHE STRING "Flags used by the compiler during Debug builds." FORCE )

    # debug without pedantic
    SET(CMAKE_CXX_FLAGS_DEBUG2 "-g -Wall" 
      CACHE STRING "Debug2 builds CMAKE CXX flags" FORCE )
    SET(CMAKE_C_FLAGS_DEBUG2 "-g -Wall" 
      CACHE STRING "Flags used by the compiler during Debug2 builds." FORCE )

    SET(CMAKE_CXX_FLAGS_RELEASE "-O3 -Wall -pedantic -Wno-long-long" 
      CACHE STRING "Flags used by the compiler during release builds." FORCE )
    SET(CMAKE_C_FLAGS_RELEASE "-O3 -Wall -pedantic" 
      CACHE STRING "Flags used by the compiler during release builds." FORCE )

    SET(CMAKE_CXX_FLAGS_RELWITHDEBINFO "-O3 -g -Wall -pedantic -Wno-long-long" 
      CACHE STRING "Flags used by the compiler during release builds." FORCE )
    SET(CMAKE_C_FLAGS_RELWITHDEBINFO "-O3 -g -Wall -pedantic" 
      CACHE STRING "Flags used by the compiler during release builds." FORCE )  

    SET(CMAKE_CXX_FLAGS_RELEASEO2 "-O2 -Wall -pedantic -Wno-long-long" 
      CACHE STRING "Flags used by the compiler during release builds." FORCE )
    SET(CMAKE_C_FLAGS_RELEASEO2 "-O2 -Wall -pedantic" 
      CACHE STRING "Flags used by the compiler during release builds." FORCE )

    #
    # our own architecture optimized builds:
    #

    # Intel Pentium4 
    SET(CMAKE_CXX_FLAGS_P4 "-O3 -march=pentium4 -Wall -pedantic -Wno-long-long " 
      CACHE STRING "Flags used by the compiler during release builds.")
    SET(CMAKE_C_FLAGS_P4 "-O3 -march=pentium4 -Wall -pedantic" 
      CACHE STRING "Flags used by the compiler." )

    SET(CMAKE_CXX_FLAGS_P4SSE "-O3 -march=pentium4 -mcpu=pentium4 -msse -msse2 -mfpmath=sse -minline-all-stringops -Wall -pedantic -Wno-long-long " 
      CACHE STRING "Flags used by the compiler during P$SSE builds.")
    SET(CMAKE_C_FLAGS_P4SSE "-O3 -march=pentium4 -mcpu=pentium4 -msse -msse2 -mfpmath=sse -minline-all-stringops -Wall -pedantic" 
      CACHE STRING "Flags used by the compiler during P4SSE builds." )

    SET(CMAKE_CXX_FLAGS_P4DEB "-O3 -march=pentium4 -g -Wall -pedantic -Wno-long-long " 
      CACHE STRING "Flags used by the compiler during P4DEB builds.")
    SET(CMAKE_C_FLAGS_P4DEB "-O3 -march=pentium4 -g -Wall -pedantic" 
      CACHE STRING "Flags used by the compiler during P4DEB builds." )

    SET(CMAKE_CXX_FLAGS_P4PROF "-O3 -march=pentium4 -g -pg -Wall -pedantic -Wno-long-long"
      CACHE STRING "Flags used by the compiler during P4PROF builds.")
    SET(CMAKE_C_FLAGS_P4PROF "-O3 -march=pentium4 -g -pg -Wall -pedantic" 
      CACHE STRING "Flags used by the compiler during P4PROF builds.")
    SET(CMAKE_EXE_LINKER_FLAGS_P4PROF "-pg" 
      CACHE STRING "Flags used by the linker during P4PROF builds.")
    SET(CMAKE_MODULE_LINKER_FLAGS_P4PROF "-pg" 
      CACHE STRING "Flags used by the linker during P4PROF builds.")

    SET(CMAKE_CXX_FLAGS_P4SSEPROF "-O3 -march=pentium4 -mcpu=pentium4 -msse -msse2 -mfpmath=sse -minline-all-stringops -g -pg -Wall -pedantic -Wno-long-long" 
      CACHE STRING "Flags used by the compiler during profiling builds.")
    SET(CMAKE_C_FLAGS_P4SSEPROF "-O3 -march=pentium4 -mcpu=pentium4 -msse -msse2 -mfpmath=sse -minline-all-stringops -g -pg -Wall -pedantic" 
      CACHE STRING "Flags used by the compiler during profiling builds.")
    SET(CMAKE_EXE_LINKER_FLAGS_P4SSEPROF "-pg" 
      CACHE STRING "Flags used by the linker during profiling builds.")
    SET(CMAKE_MODULE_LINKER_FLAGS_P4SSEPROF "-pg" 
      CACHE STRING "Flags used by the linker during profiling builds.")

    SET(CMAKE_CXX_FLAGS_P4SSEDEB "-O3 -march=pentium4 -mcpu=pentium4 -msse -msse2 -mfpmath=sse -minline-all-stringops -g -Wall -pedantic -Wno-long-long " 
      CACHE STRING "Flags used by the compiler during P4SSEDEB builds.")
    SET(CMAKE_C_FLAGS_P4SSEDEB "-O3 -march=pentium4 -mcpu=pentium4 -msse -msse2 -mfpmath=sse -minline-all-stringops -g -Wall -pedantic" 
      CACHE STRING "Flags used by the compiler during P4SSEDEB builds.")

    # Pentium4 with prescott core that supports sse3  JW
    SET(CMAKE_CXX_FLAGS_PRESCOTT "-O3 -march=prescott -mcpu=prescott -mmmx -msse -msse2 -msse3 -mfpmath=sse -minline-all-stringops -Wall -Wno-long-long" 
      CACHE STRING "Flags used by the compiler during PRESCOTT optimized builds.")
    SET(CMAKE_C_FLAGS_PRESCOTT   "-O3 -march=prescott -mcpu=prescott -mmmx -msse -msse2 -msse3 -mfpmath=sse -minline-all-stringops -Wall" 
      CACHE STRING "Flags used by the compiler during PRESCOTT optimized builds." )

    # AMD Athlon JW
    SET(CMAKE_CXX_FLAGS_ATHLON "-O3 -march=athlon -Wall -pedantic -Wno-long-long " 
      CACHE STRING "Flags used by the compiler during ATHLON builds.")
    SET(CMAKE_C_FLAGS_ATHLON "-O3 -march=athlon -Wall -pedantic" 
      CACHE STRING "Flags used by the compiler during ATHLON builds.")

    # Pentium-M
    SET(CMAKE_CXX_FLAGS_PM "-pipe -O3 -march=pentium4 -mmmx -msse -msse2 -mfpmath=sse,387 -maccumulate-outgoing-args -mno-align-stringops -fomit-frame-pointer -ffast-math -funroll-all-loops -fsched-spec-load -fprefetch-loop-arrays -ftracer -fmove-all-movables --param max-gcse-passes=4 -Wall -pedantic -Wno-long-long"
      CACHE STRING "Flags used by the compiler during PM builds.")
    SET(CMAKE_C_FLAGS_PM "-pipe -O3 -march=pentium4 -mmmx -msse -msse2 -mfpmath=sse,387 -maccumulate-outgoing-args -mno-align-stringops -fomit-frame-pointer -ffast-math -funroll-all-loops -fsched-spec-load -fprefetch-loop-arrays -ftracer -fmove-all-movables --param max-gcse-passes=4 -Wall -pedantic"
      CACHE STRING "Flags used by the compiler during PM builds." )


    # hide them (JW)
    MARK_AS_ADVANCED(
      CMAKE_CXX_FLAGS_DEBUG2
      CMAKE_C_FLAGS_DEBUG2
      CMAKE_CXX_FLAGS_P4
      CMAKE_C_FLAGS_P4
      CMAKE_CXX_FLAGS_P4DEB
      CMAKE_C_FLAGS_P4DEB
      CMAKE_CXX_FLAGS_P4SSE
      CMAKE_C_FLAGS_P4SSE
      CMAKE_CXX_FLAGS_P4PROF
      CMAKE_C_FLAGS_P4PROF
      CMAKE_EXE_LINKER_FLAGS_P4PROF
      CMAKE_MODULE_LINKER_FLAGS_P4PROF
      CMAKE_CXX_FLAGS_P4SSEPROF
      CMAKE_C_FLAGS_P4SSEPROF
      CMAKE_EXE_LINKER_FLAGS_P4SSEPROF
      CMAKE_MODULE_LINKER_FLAGS_P4SSEPROF
      CMAKE_CXX_FLAGS_P4SSEDEB
      CMAKE_C_FLAGS_P4SSEDEB
      CMAKE_CXX_FLAGS_ATHLON
      CMAKE_C_FLAGS_ATHLON
      CMAKE_CXX_FLAGS_RELEASEO2
      CMAKE_C_FLAGS_RELEASEO2
      CMAKE_CXX_FLAGS_PRESCOTT
      CMAKE_C_FLAGS_PRESCOTT
      CMAKE_CXX_FLAGS_PM
      CMAKE_C_FLAGS_PM
      )

  ENDIF(UNIX_STYLE_FLAGS)

  # ---------------------------------------------------
  # ---------------------------------------------------

  IF (WIN32_STYLE_FLAGS)

    #
    # set highest warning level (JW)
    #
    IF(CMAKE_BUILD_TOOL MATCHES "(msdev|devenv|nmake)")
      # TODO: only msdev supports the CMAKE_CXX_WARNING_LEVEL, others rely on CXX flags
      # set C++/C compilation warning level 
      # 4 = highest(pedantic)
      SET(CMAKE_CXX_WARNING_LEVEL 4 
        CACHE STRING "compiler warning level for CPP" FORCE)

      SET(CMAKE_C_WARNING_LEVEL 3
        CACHE STRING "compiler warning level for C" FORCE)

      MARK_AS_ADVANCED(CMAKE_CXX_WARNING_LEVEL CMAKE_C_WARNING_LEVEL)
    ENDIF(CMAKE_BUILD_TOOL MATCHES "(msdev|devenv|nmake)")    

    # disable warnings taht are too pedantic (for us actually)
    # 4100 : unreferenced paramter
    # 4127 : conditional expression is constant
    # 4189 : local variable initialized but not referenced
    # 4512 : could not generate assignment operator
    # 4702 : unreachable code
    SET(FLAGS_WARN_OFF "/wd4100 /wd4127 /wd4189 /wd4512 /wd4702")
    SET(CMAKE_CXX_FLAGS_DEBUG
      "${CMAKE_CXX_FLAGS_DEBUG} ${FLAGS_WARN_OFF}"
      CACHE STRING "Debug builds CMAKE CXX flags " FORCE )
    
    SET(CMAKE_CXX_FLAGS_RELEASE
      "${CMAKE_CXX_FLAGS_RELEASE} ${FLAGS_WARN_OFF}"
      CACHE STRING "Release builds CMAKE CXX flags " FORCE )
    

    #IF(NODEFAULTLIBS_OVERRIDE)
    #
    # handle system defaultlibs
    # 
    # Do not mix  debug/release  x  static/shared  x  single/multithreaded
    # version of defaultlib system libraries, e.g. libc/libcd/msvcrt
    # They are part of the Microsoft C Runtime Library
    # and contain standard C library functions such as printf, memcpy, cos, ...
    # See MSDN Linker Tools docu (LNK4098) for details.
    #
    # (1) Check the /ML, /MT or /MD settings of your project
    # (2) --> use Debug/Release/Static/Shared/Threaded specific linking
    #  
    # You should really know what you do if you change something here,
    # at least know teh exatc differnces between:
    # libc  libcmt  libcd libcmtd...
    # libcp libcpmt ...
    # msvcrt  msvcrt  msvcrtd   msvcrtd ...
    # msvcprt msvcprt msvcprtd  msvcprtd ...
    #
    # Please discuss changes because either you or me made a mistake ...
    #
    # Jan Woetzel 08/2005 - 12/2005
    #

    #MESSAGE(STATUS "DBG initializing for (Debug/Release) multithreaded DLL defaultlibs ")

    # Multithreaded using DLL (msvcrt(d).lib) /MDd /MD
    # ignore: libc.lib, libcmt.lib, msvcrt.lib, libcd.lib, libcmtd.lib
    LINK_LIBRARIES(debug msvcrtd optimized msvcrt)
    #LINK_LIBRARIES(debug cmtd    optimized cmt)
    LINK_LIBRARIES(debug libcmtd    optimized libcmt)
    SET(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} /NODEFAULTLIB:\"libc.lib\"")
    SET(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} /NODEFAULTLIB:\"libcd.lib\"")


    # HACK: TODO: move this out of init once
    # and write add/remove expression in case use CMAKE_BUILD_TYPE change (JW)
    #      IF    (CMAKE_BUILD_TYPE MATCHES ".*[rR][eE][lL].*")
    #
    #        MESSAGE(STATUS "DBG initializing for Release multithreaded DLL defaultlibs ")
    #
    #        # Debug Multithreaded using DLL (msvcrtd.lib) /MDd
    #        # ignore: libc.lib, libcmt.lib, msvcrt.lib, libcd.lib, libcmtd.lib
    #        #LINK_LIBRARIES(debug msvcrtd optimized msvcrt)
    #        SET(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} /NODEFAULTLIB:\"libc.lib\"")
    #        SET(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} /NODEFAULTLIB:\"libcd.lib\"")
    #        # SET(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} /NODEFAULTLIB:\"libcmt.lib\"")
    #        SET(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} /NODEFAULTLIB:\"libcmtd.lib\"")
    #        # SET(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} /NODEFAULTLIB:\"msvcrt.lib\"")    
    #        SET(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} /NODEFAULTLIB:\"msvcrtd.lib\"")
    #
    #      ELSE  (CMAKE_BUILD_TYPE MATCHES ".*[rR][eE][lL].*") 
    #
    #        MESSAGE(STATUS "DBG initializing for Debug multithreaded DLL defaultlibs ")
    #
    #        # Release Multithreaded using DLL (msvcrt.lib) /MD
    #        # ignore: libc.lib, libcmt.lib, libcd.lib, libcmtd.lib, msvcrtd.lib
    #        #LINK_LIBRARIES(debug msvcrtd optimized msvcrt)
    #        SET(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} /NODEFAULTLIB:\"libc.lib\"")
    #        SET(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} /NODEFAULTLIB:\"libcd.lib\"")
    #        # SET(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} /NODEFAULTLIB:\"libcmtd.lib\"")
    #        SET(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} /NODEFAULTLIB:\"msvcrt.lib\"")
    #        # SET(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} /NODEFAULTLIB:\"msvcrtd.lib\"")  
    #
    #      ENDIF (CMAKE_BUILD_TYPE MATCHES ".*[rR][eE][lL].*")

    # Debug Single-threaded static (libcd.lib)
    # ignore: libc.lib, libcmt.lib, msvcrt.lib, libcmtd.lib, msvcrtd.lib  
    #LINK_LIBRARIES(debug libcd optimized libc)
    #SET(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} /NODEFAULTLIB:\"libc.lib\"")
    #SET(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} /NODEFAULTLIB:\"libcmt.lib\"")
    #SET(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} /NODEFAULTLIB:\"libcmtd.lib\"")
    #SET(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} /NODEFAULTLIB:\"msvcrt.lib\"")
    #SET(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} /NODEFAULTLIB:\"msvcrtd.lib\"")

    # Debug Multithreaded static (libcmtd.lib)
    # ignore: libc.lib, libcmt.lib, msvcrt.lib, libcd.lib, msvcrtd.lib
    #LINK_LIBRARIES(debug libcmtd optimized libcmt)
    #SET(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} /NODEFAULTLIB:\"libc.lib\"")
    #SET(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} /NODEFAULTLIB:\"libcd.lib\"")
    #SET(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} /NODEFAULTLIB:\"libcmt.lib\"")
    #SET(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} /NODEFAULTLIB:\"msvcrt.lib\"")
    #SET(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} /NODEFAULTLIB:\"msvcrtd.lib\"")

    # Release Single-threaded static (libc.lib)
    # ignore: libcmt.lib, msvcrt.lib, libcd.lib, libcmtd.lib, msvcrtd.lib
    #LINK_LIBRARIES(debug libcd optimized libc)
    #SET(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} /NODEFAULTLIB:\"libcd.lib\"")
    #SET(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} /NODEFAULTLIB:\"libcmt.lib\"")
    #SET(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} /NODEFAULTLIB:\"libmscmtd.lib\"")
    #SET(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} /NODEFAULTLIB:\"msvcrt.lib\"")    
    #SET(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} /NODEFAULTLIB:\"msvcrtd.lib\"")

    # Release Multithreaded static (libcmt.lib)
    # ignore: libc.lib, msvcrt.lib, libcd.lib, libcmtd.lib, msvcrtd.lib
    #LINK_LIBRARIES(debug libcmtd optimized libcmt)
    #SET(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} /NODEFAULTLIB:\"libc.lib\"")
    #SET(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} /NODEFAULTLIB:\"libcd.lib\"")
    #SET(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} /NODEFAULTLIB:\"libcmtd.lib\"")
    #SET(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} /NODEFAULTLIB:\"msvcrt.lib\"")
    #SET(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} /NODEFAULTLIB:\"msvcrtd.lib\"")

    # make changes persistent
    SET(CMAKE_EXE_LINKER_FLAGS ${CMAKE_EXE_LINKER_FLAGS}
      CACHE STRING "flags for linking an executable" FORCE)

    #ENDIF(NODEFAULTLIBS_OVERRIDE)

  ENDIF(WIN32_STYLE_FLAGS)

  #
  # we are done with overriding initialzation once
  SET(DEFINEFLAGS_HAS_RUN  ON  CACHE INTERNAL "override cache entries on first run of DefineFalgs done? (jw)" FORCE)
ELSE (NOT  DEFINEFLAGS_HAS_RUN)
  # be verbose on build type for now
  #MESSAGE(STATUS "DBG DefineFlags is skipping force") 
  IF (BUILD_SHARED_LIBS)
    #MESSAGE(STATUS "DBG DefineFlags.cmake:  CMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}  SHARED")
  ELSE (BUILD_SHARED_LIBS)
    #MESSAGE(STATUS "DBG DefineFlags.cmake:  CMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}  STATIC")
  ENDIF (BUILD_SHARED_LIBS)
  #
  # do *NOT* override the cache values with FORCE here because they were already forced once. 
  # We do not want to override changes a user may has done by hand intentionally.
  #
  # Feel free to ask Jan Woetzel for details
  # 
ENDIF (NOT  DEFINEFLAGS_HAS_RUN)



# #######################
# 
# always section 
#
# #######################

#
# We do not want to override changes a user may has done by hand intentionally.
# Feel free to ask Jan Woetzel for details
#

IF (WIN32_STYLE_FLAGS)

  #
  # SHOWINCLUDES setting
  # 
  # useful for debugging include hierarchy: (jw)
  # JW

  # remove pattern we want to handle case insensitive
  # /showIncludes
  STRING(REGEX REPLACE "[/][sS][hH][oO][wW][iI][nN][cC][lL][uU][dD][eE][sS]" "\ " CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}" )

  # add pattern (again) if option specified 
  IF (SHOW_INCLUDES)
    SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /showIncludes")
  ENDIF (SHOW_INCLUDES)

  # remove space and end or beginning of line to avoid double brackets  
  CLEAN_LINE(CMAKE_CXX_FLAGS)

  # make changes persistent
  SET(CMAKE_CXX_FLAGS ${CMAKE_CXX_FLAGS}
    CACHE STRING "CXX flags used by the C++ commpiler for all builds in addition to build specific ones" FORCE)



  #
  # WARNING level setting (/W4 etc.)
  # for C++ and C code
  # JW

  # remove all existing warnignlevels, in particular multiple ones
  STRING(REGEX REPLACE "/W[0-9]"  "\ " 
    CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")

  STRING(REGEX REPLACE "/W[0-9]"  "\ " 
    CMAKE_C_FLAGS "${CMAKE_C_FLAGS}")


  # use the warnign level from option if there is on
  IF (CMAKE_CXX_WARNING_LEVEL)
    SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /W${CMAKE_CXX_WARNING_LEVEL}" )
  ELSE (CMAKE_CXX_WARNING_LEVEL)
    MESSAGE(SEND_ERROR "DefineFlags.cmake: invalid warning level CMAKE_CXX_WARNING_LEVEL=${CMAKE_CXX_WARNING_LEVEL} detected.")
  ENDIF (CMAKE_CXX_WARNING_LEVEL)

  IF (CMAKE_C_WARNING_LEVEL)
    SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} /W${CMAKE_C_WARNING_LEVEL}" )
  ELSE (CMAKE_C_WARNING_LEVEL)
    MESSAGE(SEND_ERROR "DefineFlags.cmake: invalid warning level CMAKE_C_WARNING_LEVEL=${CMAKE_C_WARNING_LEVEL} detected.")
  ENDIF (CMAKE_C_WARNING_LEVEL)

  CLEAN_LINE(CMAKE_CXX_FLAGS)
  CLEAN_LINE(CMAKE_C_FLAGS)

  # make changes persistent
  SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}" 
    CACHE STRING "CXX flags used by the C++ commpiler for all builds in addition to build specific ones" FORCE)
  SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS}" 
    CACHE STRING "C flags used by the C++ commpiler for all builds in addition to build specific ones" FORCE)

  # distinguish between Debug and Release - for install
  #SET(CMAKE_DEBUG_POSTFIX "d")

ENDIF (WIN32_STYLE_FLAGS)

