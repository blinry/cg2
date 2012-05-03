SET(Exercise03_SRC
  Ex03.cpp
  MeshObj.cpp
  ObjLoader.cpp
)
ADD_EXECUTABLE(ex03 ${Exercise03_SRC})
TARGET_LINK_LIBRARIES(
  ex03
  ${OpenGL_LIBRARIES}
  ${GLUT_LIBRARIES}
  ${GLEW_LIBRARIES}
)
