# Find the CppUnit includes and library
#
# This module defines
# CPPUNIT_INCLUDE_DIR, where to find cppunit include files, etc.
# CPPUNIT_LIBRARY, the libraries to link against to use CppUnit.
# CPPUNIT_FOUND, If false, do not try to use CppUnit.

# also defined, but not for general use are
# CPPUNIT_LIBRARY, where to find the CppUnit library.

#MESSAGE("Searching for cppunit library ")

FIND_PATH(CPPUNIT_INCLUDE_DIR cppunit/TestCase.h)

FIND_LIBRARY(CPPUNIT_LIBRARY cppunit)

IF(CPPUNIT_INCLUDE_DIR)
  IF(CPPUNIT_LIBRARY)
    SET(CPPUNIT_FOUND TRUE)
  ENDIF(CPPUNIT_LIBRARY)
ENDIF(CPPUNIT_INCLUDE_DIR)
