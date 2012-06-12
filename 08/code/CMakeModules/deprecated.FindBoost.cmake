# - Find Boost library installation 
# See www.boost.org) 
#  
#  Boost_FOUND
#  Boost_INCLUDE_DIR
#  Boost_LINK_DIRECTORIES
#
#
# DO NOT SPEND TIME ON IMPROVEMENTS !!!
# Brad and Andrew are actually developing 
# a general purpose FindBoost.cmake
# which will be included in CMake, soon. (JW)
#
# There is no need to add libs on Windows because boost 
# solves lib dependencies through pragmas in header files.
#
#
# AUTHOR
# Jan Woetzel <http://www.mip.informatik.uni-kiel.de/~jw> (07/2006)
# based on previous work from Andrew Maclean

#=====================================================================

IF ( WIN32 )
  # HACK for now (JW)
  SET(Boost_INCLUDE_DIR 
    "C:/Boost/include/boost-1_33_1"  
    CACHE PATH "Boost incdir with e.g. boost/multi_array.hpp" )
  SET(Boost_LINK_DIRECTORIES 
    "C:/Boost/lib"  
    CACHE PATH "Boost lib dir" )
  SET(Boost_FOUND 1)

ELSE ( WIN32 )

  # HACK for now (JW)
  SET(Boost_INCLUDE_DIR 
    "/opt/net/gcc41/boost/include"  
    CACHE PATH "Boost incdir with e.g. boost/multi_array.hpp" )
  SET(Boost_LINK_DIRECTORIES 
    "/opt/net/gcc41/boost/lib"  
    CACHE PATH "Boost lib dir" )
  SET(Boost_FOUND 1)
  
ENDIF ( WIN32 )

#=====================================================================
IF(NOT Boost_FOUND)
  # make FIND_PACKAGE friendly
  IF(NOT Boost_FIND_QUIETLY)
    IF(Boost_FIND_REQUIRED)
      MESSAGE(FATAL_ERROR
        "Boost required, please specify it's location.")
    ELSE(Boost_FIND_REQUIRED)
      MESSAGE(STATUS "ERROR: Boost was not found.")
    ENDIF(Boost_FIND_REQUIRED)
  ENDIF(NOT Boost_FIND_QUIETLY)
ENDIF(NOT Boost_FOUND)
