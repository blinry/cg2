SET(Exercise04_SRC
  Ex04.cpp
  MeshObj.cpp
  ObjLoader.cpp
  CameraController.cpp
)
ADD_EXECUTABLE(ex04 ${Exercise04_SRC})
TARGET_LINK_LIBRARIES(ex04 ${OpenGL_LIBRARIES} ${GLUT_LIBRARIES} ${GLEW_LIBRARIES})