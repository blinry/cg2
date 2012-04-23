# Name the project you can choose any name you want here
PROJECT(Exercise02) 

# Check requirements
CMAKE_MINIMUM_REQUIRED(VERSION 2.4.0)

# set the compiler flags
SET(CMAKE_BUILD_TYPE debug)
SET(CMAKE_CXX_FLAGS "-Wall")

# Add path to additional packages (makes it easier to include common libraries)
set(CMAKE_MODULE_PATH ${Exercise02_SOURCE_DIR}/CMakeModules/)

# Define where your executables should be put
set(EXECUTABLE_OUTPUT_PATH ${Exercise02_BINARY_DIR})

# Add required packages (e.g. libraries)
FIND_PACKAGE(OpenGL 3.3 REQUIRED)
FIND_PACKAGE(GLEW REQUIRED)
FIND_PACKAGE(GLUT REQUIRED)

# Set include directories containing used header files
INCLUDE_DIRECTORIES(
  ${Exercise02_SOURCE_DIR}/include/
)

# Set link directories for addiontional libraries
LINK_DIRECTORIES(
  ${Exercise02_SOURCE_DIR}/lib/
)

# Tell CMake to process the sub-directories
ADD_SUBDIRECTORY(src)
